import requests
import os
import configparser

adminBaseUrl = 'http://kong:8001'


def createAdminService():
  adminApiPayload = {"name": "adminApi", "protocol": "http", "port": 8001, "host": "127.0.0.1"}
  requests.post(url=adminBaseUrl + '/services', data=adminApiPayload, verify=False)
  requests.post(url=adminBaseUrl + '/services/adminApi/plugins', data={"name": "key-auth"}, verify=False)

def createAdminRoute():
  createAdminService()
  payload = {"name": "adminApi", "protocols": ["http", "https"], "paths": ["/admin-api"]}
  response = requests.post(adminBaseUrl + '/services/adminApi/routes', data=payload, verify=False)

def getApiKey():
  config = configparser.ConfigParser()
  apikeyfile = os.environ["kong_apikey_file"]
  config.read(apikeyfile)
  return config['kong-apikey']['apikey']

def createConsumer():
  apikey = getApiKey()
  keyAuthUrl = adminBaseUrl + '/consumers/admin/key-auth'
  adminConsumerResponse = requests.get(keyAuthUrl)
  if adminConsumerResponse.status_code == 200:
    if adminConsumerResponse.json()["data"][0]["key"] != apikey:
      requests.delete(keyAuthUrl + '/' + adminConsumerResponse.json()["data"][0]["id"])
      requests.post(keyAuthUrl, data={"key": apikey}, verify=False)
  else:
    requests.post(adminBaseUrl + '/consumers', data={"username": "admin"}, verify=False)
    requests.post(keyAuthUrl, data={"key": apikey}, verify=False)

def createAdmin():
  createConsumer()
  adminRouteResponse = requests.get(adminBaseUrl + '/services/adminApi')
  if adminRouteResponse.status_code == 404:
    createAdminRoute()

createAdmin()
