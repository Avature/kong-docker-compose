import re
from unittest import TestCase
from pact import Verifier
import os
import requests

PACT_BROKER_URL = "http://localhost:9292"
PACT_BROKER_USERNAME = "pactbroker"
PACT_BROKER_PASSWORD = "pactbroker"

PROVIDER_HOST = "admin.kong-server.com"
PROVIDER_PORT = 443
PROVIDER_URL = f"https://{PROVIDER_HOST}:{PROVIDER_PORT}"

PROVIDER_STATE_ENDPOINT="http://localhost:9281"

class TestVerifyContracts(TestCase):
  def setUp(self):
    self.verifier = Verifier(provider="KongDockerCompose", provider_base_url=PROVIDER_URL)
    package_version = (os.environ.get("PACKAGE_VERSION") or '_empty_version_~_empty_branch_-_empty_commit_')
    package_version_parts = re.search('([0-9\.]+)~([a-zA-Z0-9_\-]+)-([a-z0-9]+)', package_version)
    self.version = package_version_parts[1]
    self.branch_name = package_version_parts[2]
    self.commit_sha1 = package_version_parts[3]
    print(f"Identified provider | version: {self.version}, branch: {self.branch_name}, commit: {self.commit_sha1}")

  def __broker_opts(self):
    return {
      "broker_username": os.environ.get("PACT_BROKER_USERNAME") or PACT_BROKER_USERNAME,
      "broker_password": os.environ.get("PACT_BROKER_PASSWORD") or PACT_BROKER_PASSWORD,
      "broker_url": os.environ.get("PACT_BROKER_URL") or PACT_BROKER_URL,
      "publish_version": self.version,
      "provider_tags": [self.branch_name,  self.version, self.commit_sha1],
      "publish_verification_results": True,
    }

  def test_state_endpoint(self):
    response_from_state_endpoint = requests.get(f"{PROVIDER_STATE_ENDPOINT}/alive")
    self.assertEqual(b'It\'s Alive!', response_from_state_endpoint.content)

  def test_user_service_provider_against_broker(self):
    success, logs = self.verifier.verify_with_broker(
        **self.__broker_opts(),
        verbose=True,
        provider_states_setup_url=f"{PROVIDER_STATE_ENDPOINT}/provider_states",
        enable_pending=False,
        validateSSL=False
    )
    self.assertTrue(success == 0)
