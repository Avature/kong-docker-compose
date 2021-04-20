import json
import requests
import os
import configparser
import json
import logging

admin_base_url = 'http://kong:8001'

class Fixture:
  def __init__(self):
    self.previously_installed_plugins = {}

  def get_admin_plugins(self):
    return [
      {"target":"routes/adminApi", "payload": {"name": "key-auth", "config": {"key_names": ['X-Kong-Admin-Key']}}},
      {"target":"services/adminApi", "payload": {
        "name": "file_log_censored",
        "config": {
          "path":"/home/kong/log/admin-api.log",
          "reopen": True,
          "censored_fields": ["request.headers.x-kong-admin-key"]
      }}},
      {"target":"routes/adminApiRegisterInstance", "payload": {"name": "mtls_certs_manager", "config": {
        "ca_private_key_path": "/home/kong/certs/server-ca-key.key",
        "ca_certificate_path": "/home/kong/certs/server-ca-cert.crt"
      }}},
      {"target":"routes/adminApi", "payload": {"name": "client_consumer_validator", "config": {
        "consumer_identifier":"username",
        "rules": {
          "rule_1": {
            "request_path_activation_regex": "(.*)",
            "search_in_header": "X-Certificate-CN-Header",
            "expected_consumer_identifier_regex": "(.*)",
            "methods": ["GET", "HEAD", "PUT", "PATCH", "POST", "DELETE", "OPTIONS", "TRACE", "CONNECT"]
          },
          "rule_2": {
            "request_path_activation_regex": "/services/(.*)/plugins",
            "search_in_json_payload": "config.replace.headers.1",
            "expected_consumer_identifier_regex": "Host:(.*)",
            "methods": ["POST", "PUT", "PATCH"]
          }
        }
      }}},
      {"target": "/", "payload": {"name": "prometheus"}}
    ]

  def create_admin_service(self):
    admin_api_response = requests.get(admin_base_url + '/services/adminApi')
    if admin_api_response.status_code == 404:
      admin_api_payload = {"name": "adminApi", "protocol": "http", "port": 8001, "host": "127.0.0.1"}
      self.post_or_fail(url=admin_base_url + '/services', data=admin_api_payload, verify=False)

  def create_admin_route(self):
    self.create_route('/admin-api', 'adminApi', [])

  def create_register_instance_route(self):
    self.create_route('/admin-api/instances/register', 'adminApiRegisterInstance', ["POST"])

  def create_route(self, route_path, route_name, methods):
    route_response = requests.get(admin_base_url + '/services/adminApi/routes/' + route_name)
    if route_response.status_code == 404:
      payload = {"name": route_name, "protocols": ["http", "https"], "paths": [route_path], "methods": methods}
      self.post_or_fail(admin_base_url + '/services/adminApi/routes', data=payload, verify=False)

  def get_api_key(self):
    config = configparser.ConfigParser()
    api_key_file = os.environ["kong_apikey_file"]
    config.read(api_key_file)
    return config['kong-apikey']['apikey']

  def create_consumer(self):
    api_key = self.get_api_key()
    key_auth_url = admin_base_url + '/consumers/admin/key-auth'
    admin_consumer_response = requests.get(key_auth_url)
    if admin_consumer_response.status_code == 200 and admin_consumer_response.json()["data"]:
      if admin_consumer_response.json()["data"][0]["key"] != api_key:
        self.__renew_api_key(api_key, key_auth_url, admin_consumer_response.json()["data"][0]["id"])
    else:
      self.post_or_fail(admin_base_url + '/consumers', data={"username": "admin"}, verify=False)
      self.post_or_fail(key_auth_url, data={"key": api_key}, verify=False)

  def __renew_api_key(self, api_key, key_auth_url, id):
    requests.delete(key_auth_url + '/' + id)
    self.post_or_fail(key_auth_url, data={"key": api_key}, verify=False)

  def get_previous_plugins_for_target(self, target):
    if target not in self.previously_installed_plugins:
      previous_plugins = requests.get(self.get_plugins_path_for_target(target)).json()["data"]
      self.previously_installed_plugins[target] = list(map(lambda plugin: plugin["name"], previous_plugins))
    return self.previously_installed_plugins[target]

  def target_has_plugin(self, plugin_name, target):
    return plugin_name in self.get_previous_plugins_for_target(target)

  def add_plugins(self):
    for plugin_config in self.get_admin_plugins():
      self.add_plugin(plugin_config)

  def add_plugin(self, plugin_config):
    target = plugin_config["target"]
    payload = plugin_config["payload"]
    plugin_name = payload["name"]
    if (not self.target_has_plugin(plugin_name, target)):
      self.post_or_fail(
        url=self.get_plugins_path_for_target(target),
        data=json.dumps(payload),
        verify=False,
        headers={"Content-Type": "application/json"}
      )
      self.previously_installed_plugins[target].append(plugin_name)

  def get_plugins_path_for_target(self, target):
    separator = '' if target.endswith('/') else '/'
    return f"{admin_base_url}{separator}{target}{separator}plugins"

  def post_or_fail(self, url, data, verify, headers = {}):
    response = requests.post(url=url, data=data, verify=verify, headers=headers)
    if (response.status_code != 201):
      logging.error(f'Error trying to post: {response.text}, target URL: {url}, request body: {response.request.body}')
      exit(1)
    return response

  def run(self):
    self.create_consumer()
    self.create_admin_service()
    self.create_admin_route()
    self.create_register_instance_route()
    self.add_plugins()
