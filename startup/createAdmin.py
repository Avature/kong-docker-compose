import requests
import os
import configparser
import json

admin_base_url = 'http://kong:8001'
admin_api_plugins = [
  {"name": "key-auth"},
  {"name": "file-log", "config.path":"/home/kong/log/admin-api.log", "config.reopen": "true"}
]

def create_admin_service():
  admin_api_payload = {"name": "adminApi", "protocol": "http", "port": 8001, "host": "127.0.0.1"}
  requests.post(url=admin_base_url + '/services', data=admin_api_payload, verify=False)

def create_cn_pre_function():
  script_file_path = os.path.dirname(__file__) + "/read-cn-header.lua"
  script_file = open(script_file_path, "r")
  read_cn_script = script_file.read()
  payload = {
    "name": "pre-function",
    "config.functions": [
      read_cn_script
    ]
  }
  requests.post(url=adminBaseUrl + '/services/adminApi/plugins', data = payload, verify=False)

def create_admin_route():
  create_admin_service()
  payload = {"name": "adminApi", "protocols": ["http", "https"], "paths": ["/admin-api"]}
  response = requests.post(admin_base_url + '/services/adminApi/routes', data=payload, verify=False)

def get_api_key():
  config = configparser.ConfigParser()
  api_key_file = os.environ["kong_apikey_file"]
  config.read(api_key_file)
  return config['kong-apikey']['apikey']

def create_consumer():
  api_key = get_api_key()
  key_auth_url = admin_base_url + '/consumers/admin/key-auth'
  admin_consumer_response = requests.get(key_auth_url)
  if admin_consumer_response.status_code == 200 and admin_consumer_response.json()["data"]:
    if admin_consumer_response.json()["data"][0]["key"] != api_key:
      requests.delete(key_auth_url + '/' + admin_consumer_response.json()["data"][0]["id"])
      requests.post(key_auth_url, data={"key": api_key}, verify=False)
  else:
    requests.post(admin_base_url + '/consumers', data={"username": "admin"}, verify=False)
    requests.post(key_auth_url, data={"key": api_key}, verify=False)

def create_admin():
  create_consumer()
  admin_route_response = requests.get(admin_base_url + '/services/adminApi')
  if admin_route_response.status_code == 404:
    create_admin_route()
    create_cn_pre_function()
  add_plugins()

def add_plugins():
  admin_plugins_response = requests.get(admin_base_url + '/services/adminApi/plugins').json()["data"]
  for plugin in admin_api_plugins:
    add_plugin(plugin, admin_plugins_response)

def add_plugin(plugin_config, admin_plugins):
  if (has_not_plugin(plugin_config["name"], admin_plugins)):
    requests.post(url=admin_base_url + '/services/adminApi/plugins', data=plugin_config, verify=False)

def has_not_plugin(plugin_name, plugins):
  return not any(plugin["name"] == plugin_name for plugin in plugins)

if __name__ == "__main__":
  create_admin()
