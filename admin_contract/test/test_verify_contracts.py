import re
from unittest import TestCase
from pact import Verifier
import os
import requests
from .package_version_parser import PackageVersionParser

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
    parsed_version_info = PackageVersionParser().parse(os.environ.get("PACKAGE_VERSION"))
    self.version = parsed_version_info['version']
    self.branch_name = parsed_version_info['branch_name']
    self.commit_sha1 = parsed_version_info['commit_sha1']
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
