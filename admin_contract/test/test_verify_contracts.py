from unittest import TestCase
from pact import Verifier
import os

PACT_BROKER_URL = "http://localhost:9292"
PACT_BROKER_USERNAME = "pactbroker"
PACT_BROKER_PASSWORD = "pactbroker"

PROVIDER_HOST = "admin.kong-server.com"
PROVIDER_PORT = 443
PROVIDER_URL = f"https://{PROVIDER_HOST}:{PROVIDER_PORT}"

class TestVerifyContracts(TestCase):
  def __broker_opts(self):
    return {
      "broker_username": os.environ.get("PACT_BROKER_USERNAME") or PACT_BROKER_USERNAME,
      "broker_password": os.environ.get("PACT_BROKER_PASSWORD") or PACT_BROKER_PASSWORD,
      "broker_url": os.environ.get("PACT_BROKER_URL") or PACT_BROKER_URL,
      "publish_version": "0.0.19",
      "publish_verification_results": True,
    }

  def setUp(self):
    self.verifier = Verifier(provider="KongDockerCompose", provider_base_url=PROVIDER_URL)

  # TODO: Add a povider state setup endpoint that allows to control Kong's initial state (#747767)
  def test_user_service_provider_against_broker(self):
    success, logs = self.verifier.verify_with_broker(
        **self.__broker_opts(),
        verbose=True,
        # provider_states_setup_url=f"{PROVIDER_URL}/_pact/provider_states",
        enable_pending=False,
        validateSSL=False
    )
    self.assertTrue(success == 0)
