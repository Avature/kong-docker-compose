import json
import os

class Config:
  PLUGINS_CONFIG = [
      {"target":"routes/adminApi", "payload": {"name": "key-auth", "config": {"key_names": ['X-Kong-Admin-Key']}}},
      {"target":"services/adminApi", "payload": {
        "name": "file_log_censored",
        "config": {
          "path":"/var/log/admin-api.log",
          "reopen": True,
          "censored_fields": ["request.headers.x-kong-admin-key"]
      }}},
      {"target":"routes/adminApiRegisterInstance", "payload": {"name": "mtls_certs_manager", "config": {
        "ca_private_key_path": "/home/kong/certs/server-ca-key.key",
        "ca_certificate_path": "/home/kong/certs/server-ca-cert.crt"
      }}},
      {"target":"routes/adminApiRenewInstance", "payload": {"name": "mtls_certs_manager", "config": {
        "ca_private_key_path": "/home/kong/certs/server-ca-key.key",
        "ca_certificate_path": "/home/kong/certs/server-ca-cert.crt",
        "plugin_endpoint_usage": "renew_instance"
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
      {"target":"routes/adminApiRenewInstance", "payload": {"name": "key-auth", "config": {"key_names": ['X-Kong-Admin-Key']}}},
      {"target":"routes/adminApiRenewInstance", "payload": {"name": "client_consumer_validator", "config": {
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

  def _get_env_array(self):
    env_value = os.getenv('STARTUP_PLUGINS_CONFIG_ARRAY_JSON')
    return json.loads(env_value) if env_value else []

  def get_plugins_config(self):
    return self.PLUGINS_CONFIG + self._get_env_array()
