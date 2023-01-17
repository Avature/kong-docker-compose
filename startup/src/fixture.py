import requests
import json
import logging
from config import Config
import time

admin_base_url = 'http://kong:8001'

class Fixture:
  def __init__(self):
    self.previously_installed_plugins = {}
    self.config = Config()

  def get_admin_plugins(self):
    return self.config.get_plugins_config()

  def create_admin_service(self):
    admin_api_response = requests.get(admin_base_url + '/services/adminApi')
    if admin_api_response.status_code == 404:
      admin_api_payload = {"name": "adminApi", "protocol": "http", "port": 8001, "host": "127.0.0.1"}
      self.post_or_fail(url=admin_base_url + '/services', data=admin_api_payload, verify=False)

  def create_admin_route(self):
    self.create_route('/admin-api', 'adminApi', [])

  def create_register_instance_route(self):
    self.create_route('/admin-api/instances/register', 'adminApiRegisterInstance', ["POST"])

  def create_renew_instance_route(self):
    self.create_route('/admin-api/instances/renew', 'adminApiRenewInstance', ["POST"])

  def create_route(self, route_path, route_name, methods):
    route_response = requests.get(admin_base_url + '/services/adminApi/routes/' + route_name)
    if route_response.status_code == 404:
      payload = {"name": route_name, "protocols": ["http", "https"], "paths": [route_path], "methods": methods}
      self.post_or_fail(admin_base_url + '/services/adminApi/routes', data=payload, verify=False)

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
    try:
      print("Creating Kong Fixture...")
      self.create_admin_service()
      self.create_admin_route()
      self.create_register_instance_route()
      self.create_renew_instance_route()
      self.add_plugins()
      print("Fixture created OK.")
    except requests.exceptions.ConnectionError:
      print("Failed connecting to kong. Retrying in 1 seconds...")
      time.sleep(1)
      self.run()
