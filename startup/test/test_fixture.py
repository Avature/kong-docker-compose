import json
from unittest import mock, TestCase
import os
import responses
from src.fixture import Fixture
from src.config import Config
from src.pluginsComparator import PluginsComparator
from test.config_preparation import ConfigPreparation
from test.assertion_helper import AssertionHelper

from test.debugger import run_debugger
if (os.environ.get("ENABLE_DEBUGGER")):
  run_debugger()

class TestFixture(TestCase):
  def setUp(self):
    self.mocked_config = mock.Mock()
    self.config_preparation = ConfigPreparation(self.mocked_config)
    self.assertion_helper = AssertionHelper(self)
    self.config_preparation._admin_api_base_services_and_routes_creation_mocks()
    default_read_config = Config().get_plugins_config()
    self.mocked_config.get_plugins_config = mock.MagicMock(return_value=default_read_config)
    self.subject = Fixture(self.mocked_config, PluginsComparator())

  @responses.activate
  def test_run_create_all_succeed(self):
    responses.add(responses.GET, 'http://kong:8001/routes/adminApi/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApi/plugins', status=201, json={"id":"uuid-of-created-plugin1"})
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/plugins', status=201, json={"id":"uuid-of-created-plugin2"})
    responses.add(responses.GET, 'http://kong:8001/routes/adminApiRegisterInstance/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApiRegisterInstance/plugins', status=201, json={"id":"uuid-of-created-plugin3"})
    responses.add(responses.GET, 'http://kong:8001/routes/adminApiRenewInstance/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApiRenewInstance/plugins', status=201, json={"id":"uuid-of-created-plugin4"})
    responses.add(responses.GET, 'http://kong:8001/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/plugins', status=201, json={"id":"uuid-of-created-plugin5"})
    self.subject.run()
    self.assertion_helper.assert_call_count('routes/adminApi/plugins', 3)
    self.assertion_helper.assert_call_count('routes/adminApiRegisterInstance/plugins', 2)
    self.assertion_helper.assert_call_count('routes/adminApiRenewInstance/plugins', 4)
    self.assertion_helper.assert_call_count('services/adminApi/plugins', 2)

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
    self.config_preparation._mock_plugin_not_exists()
    self.config_preparation._mock_plugin_expected_config('/newer/path/admin-api.log')
    self.subject.run()
    self.assertion_helper.assert_upsert_call({
      "name": "file_log_censored",
      "config": {
        "path": "/newer/path/admin-api.log",
        "reopen": True,
        "censored_fields": ["request.headers.x-kong-admin-key"]
      }
    })
    self.assertion_helper.assert_call_count('services/adminApi/plugins', 2)
    self.assertion_helper.assert_call_count('services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 0)

  @responses.activate
  def test_plugin_is_created_and_after_that_config_is_changed_with_a_correction(self):
    self.config_preparation._mock_plugin_not_exists()
    self.config_preparation._mock_plugin_expected_config_with_correction('/newer/path/admin-api.log')
    responses.patch(
      "http://kong:8001/services/adminApi/plugins/an-id-generated-by-server",
      body='{"id":"an-id-generated-by-server"}',
      status=200,
      content_type="application/json"
    )
    self.subject.run()
    self.assertion_helper.assert_upsert_call({
      "name": "file_log_censored",
      "config": {
        "path": "/newer/path/admin-api.log",
        "reopen": True,
        "censored_fields": ["request.headers.x-kong-admin-key"]
      }
    })
    self.assertion_helper.assert_upsert_call({
      "id": "an-id-generated-by-server",
      "name": "file_log_censored",
      "enabled": "false"
    }, 10)
    self.assertion_helper.assert_call_count('services/adminApi/plugins', 2)
    self.assertion_helper.assert_call_count('services/adminApi/plugins/an-id-generated-by-server', 1)

  @responses.activate
  def test_plugins_are_updated_because_no_matching_config(self):
    self.config_preparation._mock_plugin_exists(file_path="/home/kong/log/admin-api.log")
    self.config_preparation._mock_plugin_expected_config(file_path="/var/log/admin-api.log")
    responses.patch(
      "http://kong:8001/services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin",
      body='{"id":"an-arbitrary-uuid-for-the-plugin"}',
      status=200,
      content_type="application/json"
    )
    self.subject.run()
    self.assertion_helper.assert_upsert_call({
      "name": "file_log_censored",
      "id": 'an-arbitrary-uuid-for-the-plugin',
      "config": {
        "path": "/var/log/admin-api.log",
        "reopen": True,
        "censored_fields": ["request.headers.x-kong-admin-key"]
      }
    })
    self.assertion_helper.assert_call_count('services/adminApi/plugins', 1)
    self.assertion_helper.assert_call_count('services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 1)

  @responses.activate
  def test_plugins_exists_but_are_not_updated_because_config_matches_ok(self):
    self.config_preparation._mock_plugin_exists(file_path="/other/path/already/matched/admin-api.log")
    self.config_preparation._mock_plugin_expected_config(file_path="/other/path/already/matched/admin-api.log")
    self.subject.run()
    self.assertion_helper.assert_call_count('services/adminApi/plugins', 1)
    self.assertion_helper.assert_call_count('services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 0)

  @responses.activate
  def test_prometheus_plugin_requires_no_config(self):
    self.config_preparation._mock_plugin_exists(full_config={"name":"prometheus", "config": {}})
    self.config_preparation._mock_plugin_expected_config(full_config={"target":"services/adminApi", "payload": {"name":"prometheus"}})
    self.subject.run()
    self.assertion_helper.assert_call_count('services/adminApi/plugins', 1)
    self.assertion_helper.assert_call_count('services/adminApi/plugins/an-arbitrary-uuid-for-the-plugin', 0)
