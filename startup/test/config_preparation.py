import json
from unittest import mock
import responses

class ConfigPreparation():
  def __init__(self, mocked_config):
    self.mocked_config = mocked_config

  def _mock_plugin_expected_config(self, file_path = '', full_config=None):
    expected_plugins_configs = self._get_expected_config(file_path, full_config)
    self.mocked_config.get_plugins_config = mock.MagicMock(return_value=expected_plugins_configs)

  def _get_expected_config(self, file_path = '', full_config=None):
    return [
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

  def _mock_plugin_expected_config_with_correction(self, file_path, full_config=None):
    expected_plugins_configs = self._get_expected_config(file_path, full_config)
    expected_plugins_configs.append(
      {
        "target":"services/adminApi",
        "payload": {"enabled": "false", "name":"file_log_censored"}
      }
    )
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
      body='{"id":"an-id-generated-by-server"}',
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

  def _assert_upsert_call(self, expected_body, call_number=9):
    self.test.assertEqual(
      json.loads(responses.calls[call_number].request.body),
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
