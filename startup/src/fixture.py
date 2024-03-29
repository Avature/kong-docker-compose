import requests
import logging
import time
import os

admin_base_url = 'http://kong:8001'

class Fixture:
  def __init__(self, config, plugins_comparator):
    self.plugins_comparator = plugins_comparator
    self.previously_installed_plugins = {}
    self.config = config

  def get_admin_plugins(self):
    return self.config.get_plugins_config()

  def create_admin_service(self):
    admin_api_response = requests.get(admin_base_url + '/services/adminApi')
    if admin_api_response.status_code == 404:
      admin_api_payload = {"name": "adminApi", "protocol": "http", "port": 8001, "host": "127.0.0.1"}
      self.save_or_fail(url=admin_base_url + '/services', data=admin_api_payload, verify=False)

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
      self.save_or_fail(admin_base_url + '/services/adminApi/routes', data=payload, verify=False)

  def get_previous_plugins_for_target(self, target):
    if target not in self.previously_installed_plugins:
      previous_plugins = requests.get(self.get_plugins_path_for_target(target)).json()["data"]
      self.previously_installed_plugins[target] = {}
      for plugin in previous_plugins:
        self.previously_installed_plugins[target][plugin['name']] = plugin
    return self.previously_installed_plugins[target]

  def target_has_plugin(self, plugin_name, target):
    return plugin_name in self.get_previous_plugins_for_target(target)

  def is_plugin_config_changed_or_missing(self, target, plugin_expected_config):
    plugin_name = plugin_expected_config['name']
    current_config = self._get_current_config(target, plugin_name)
    if (current_config):
      return self.plugins_comparator.plugin_has_different_config(
        current_config,
        plugin_expected_config
      )
    return True

  def _get_current_config(self, target, plugin_name):
    plugins_on_target = self.get_previous_plugins_for_target(target)
    if (plugin_name in plugins_on_target):
      return plugins_on_target[plugin_name]
    return None

  def add_plugins(self):
    for plugin_config in self.get_admin_plugins():
      self.add_plugin(plugin_config)

  def add_plugin(self, plugin_config):
    target = plugin_config["target"]
    payload = plugin_config["payload"]
    plugin_name = payload["name"]
    has_the_plugin = self.target_has_plugin(plugin_name, target)
    plugin_changed_or_missing = self.is_plugin_config_changed_or_missing(target, payload)
    if (plugin_changed_or_missing):
      if (has_the_plugin):
        payload['id'] = self._get_current_config(target, plugin_name)['id']
      print("Plugin %s config %s on target %s, updating..." % (plugin_name, 'changed' if has_the_plugin else 'missing', target))
      response = self.save_or_fail(
        url=self.get_plugins_path_for_target(target),
        data=payload,
        verify=False
      )
      payload['id'] = response.json()['id']
      self.previously_installed_plugins[target][plugin_name] = payload
    else:
      print("No changes detected on target %s, plugin %s, skipping." % (target, plugin_name))

  def get_plugins_path_for_target(self, target):
    separator = '' if target.endswith('/') else '/'
    return f"{admin_base_url}{separator}{target}{separator}plugins"

  def save_or_fail(self, url, data, verify):
    is_creating = not 'id' in data
    http_method = 'POST' if is_creating else 'PATCH'
    resource_uri = url if is_creating else f"{url}/{data['id']}"
    response = requests.request(http_method, url=resource_uri, json=data, verify=verify, headers={"Content-Type": "application/json"})
    if (not ((is_creating and response.status_code == 201) or (not is_creating and response.status_code == 200))):
      action = 'post' if is_creating else 'patch'
      logging.error(f'Error trying to {action}: {response.text}, target URL: {url}, request body: {response.request.body}')
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
      self._retryIfNeeded()

  def _retryIfNeeded(self):
    if (os.environ.get('RETRY_ON_ERROR') == "true"):
      print("Failed connecting to kong. Retrying in 1 seconds...")
      time.sleep(1)
      self.run()
    else:
      print("Retrial is disabled, exiting")
      exit(1)
