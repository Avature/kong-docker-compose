from unittest import TestCase
from pact import Verifier

PACT_BROKER_URL = "http://localhost:9292"
PACT_BROKER_USERNAME = "pactbroker"
PACT_BROKER_PASSWORD = "pactbroker"

PROVIDER_HOST = "admin.kong-server.com"
PROVIDER_PORT = 443
PROVIDER_URL = f"https://{PROVIDER_HOST}:{PROVIDER_PORT}"

class TestVerifyContracts(TestCase):
  def __broker_opts(self):
    return {
      "broker_username": PACT_BROKER_USERNAME,
      "broker_password": PACT_BROKER_PASSWORD,
      "broker_url": PACT_BROKER_URL,
      "publish_version": "0.0.19",
      "publish_verification_results": True,
    }

  def setUp(self):
    self.verifier = Verifier(provider="KongDockerCompose", provider_base_url=PROVIDER_URL)

  def test_user_service_provider_against_broker(self):
    success, logs = self.verifier.verify_with_broker(
        **self.__broker_opts(),
        verbose=True,
        # provider_states_setup_url=f"{PROVIDER_URL}/_pact/provider_states",
        enable_pending=False,
        validateSSL=False
    )
    self.assertTrue(success == 0)

  # def test_user_service_provider_against_pact(self):
  #     output, logs = self.verifier.verify_pacts(
  #         "../pacts/userserviceclient-userservice.json",
  #         verbose=False,
  #         provider_states_setup_url="{}/_pact/provider_states".format(PROVIDER_URL),
  #     )
  #     self.assertTrue(output == 0)
