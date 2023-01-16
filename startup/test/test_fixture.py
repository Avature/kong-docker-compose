import json
from unittest import mock, TestCase
import os
import responses
from src.fixture import Fixture
from src.config import Config
from src.pluginsComparator import PluginsComparator

from test.debugger import run_debugger
if (os.environ.get("ENABLE_DEBUGGER")):
  run_debugger()

class TestFixture(TestCase):
  def setUp(self):
    self._admin_api_base_services_and_routes_creation_mocks()
    self.mocked_config = mock.Mock()
    default_read_config = Config().get_plugins_config()
    self.mocked_config.get_plugins_config = mock.MagicMock(return_value=default_read_config)
    self.subject = Fixture(self.mocked_config, PluginsComparator())

  @responses.activate
  def test_run_create_all_succeed(self):
    responses.add(responses.GET, 'http://kong:8001/routes/adminApi/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApi/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/routes/adminApiRegisterInstance/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApiRegisterInstance/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/routes/adminApiRenewInstance/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApiRenewInstance/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/plugins', status=201)
    self.subject.run()
    self.assertTrue(responses.assert_call_count('http://kong:8001/routes/adminApi/plugins', 3))
    self.assertTrue(responses.assert_call_count('http://kong:8001/routes/adminApiRegisterInstance/plugins', 2))
    self.assertTrue(responses.assert_call_count('http://kong:8001/routes/adminApiRenewInstance/plugins', 4))
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins', 2))

  def test_get_admin_plugins(self):
    result = self.subject.get_admin_plugins()
    self.assertEqual(len(result), 8)

  @responses.activate
  def test_create_admin_service_and_failed(self):
    responses.remove(responses.GET, 'http://kong:8001/services/adminApi')
    responses.remove(responses.POST, 'http://kong:8001/services')
    responses.add(responses.GET, 'http://kong:8001/services/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services', status=404)
    with self.assertRaises(SystemExit):
      self.subject.create_admin_service()
    self.assertEqual(responses.calls[1].request.body, b'{"name": "adminApi", "protocol": "http", "port": 8001, "host": "127.0.0.1"}')

  @responses.activate
  def test_plugins_are_created_because_they_not_exist(self):
    self._mock_plugin_not_exists()
    self._mock_plugin_expected_config('/newer/path/admin-api.log')
    self.subject.run()
    self._assert_upsert_call({
      "name": "file_log_censored",
      "config": {
        "path": "/newer/path/admin-api.log",
        "reopen": True,
        "censored_fields": ["request.headers.x-kong-admin-key"]
      }
    })
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins', 2))
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 0))

  @responses.activate
  def test_plugins_are_updated_because_no_matching_config(self):
    self._mock_plugin_exists(file_path="/home/kong/log/admin-api.log")
    self._mock_plugin_expected_config(file_path="/var/log/admin-api.log")
    responses.patch(
      "http://kong:8001/services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin",
      body='{}',
      status=201,
      content_type="application/json"
    )
    self.subject.run()
    self._assert_upsert_call({
      "name": "file_log_censored",
      "id": 'an-arbitrary-uuid-for-the-plugin',
      "config": {
        "path": "/var/log/admin-api.log",
        "reopen": True,
        "censored_fields": ["request.headers.x-kong-admin-key"]
      }
    })
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins', 1))
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 1))

  @responses.activate
  def test_plugins_exists_but_are_not_updated_because_config_matches_ok(self):
    self._mock_plugin_exists(file_path="/other/path/already/matched/admin-api.log")
    self._mock_plugin_expected_config(file_path="/other/path/already/matched/admin-api.log")
    self.subject.run()
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins', 1))
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 0))

  @responses.activate
  def test_prometheus_plugin_requires_no_config(self):
    self._mock_plugin_exists(full_config={"name":"prometheus", "config": {}})
    self._mock_plugin_expected_config(full_config={"target":"services/adminApi", "payload": {"name":"prometheus"}})
    self.subject.run()
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins', 1))
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 0))

  def _mock_plugin_expected_config(self, file_path = '', full_config=None):
    expected_plugins_configs = [
      full_config if full_config is not None else {
        "target":"services/adminApi",
        "payload": {
          "name": "file_log_censored",
          "config": {
            "path": file_path,
            "reopen": True,
            "censored_fields": ["request.headers.x-kong-admin-key"]
          }
        }
      }
    ]
    self.mocked_config.get_plugins_config = mock.MagicMock(return_value=expected_plugins_configs)

  def _mock_plugin_not_exists(self):
    responses.get(
      "http://kong:8001/services/adminApi/plugins",
      body='''{
        "next": null,
        "data": []
      }''',
      status=200,
      content_type="application/json"
    )
    responses.post(
      "http://kong:8001/services/adminApi/plugins",
      body='{}',
      status=201,
      content_type="application/json"
    )

  def _mock_plugin_exists(self, file_path = '', full_config=None):
    payload = json.dumps({
      "next": None,
      "data": [
        full_config if full_config is not None else {
          "id":"an-arbitrary-uuid-for-the-plugin",
          "service": {
            "name": "adminApi"
          },
          "enabled": True,
          "name": "file_log_censored",
            "config": {
              "aConfigThatIsNotImportant": None,
              "otherConfigNotSoImportant": {
                "subkeys": None
              },
              "reopen": True,
              "path": file_path,
              "censored_fields": [
                "request.headers.x-kong-admin-key"
              ]
            }
        }
      ]
    })
    responses.get(
      "http://kong:8001/services/adminApi/plugins",
        body=payload,
        status=200,
        content_type="application/json"
    )

  def _assert_upsert_call(self, expected_body):
    self.assertEqual(
      json.loads(responses.calls[9].request.body),
      expected_body
    )

  def _admin_api_base_services_and_routes_creation_mocks(self):
    responses.add(responses.GET, 'http://kong:8001/consumers/admin/key-auth', status=404)
    responses.add(responses.POST, 'http://kong:8001/consumers', status=201)
    responses.add(responses.POST, 'http://kong:8001/consumers/admin/key-auth', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/routes/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/routes', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/routes/adminApiRegisterInstance', status=404)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/routes/adminApiRenewInstance', status=404)
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/routes', status=201)
