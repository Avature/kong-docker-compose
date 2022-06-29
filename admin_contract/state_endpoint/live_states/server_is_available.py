from .base_state import BaseState

class ServerIsAvailable(BaseState):
  def apply(self):
    print("Asserting that all the admin endpoints are available")
    self._assert_url_responds_ok(ServerIsAvailable.DIRECT_ADMIN_HOST)
    self._assert_url_responds_ok('https://admin.kong-server.com/metrics')
    self._assert_url_responds_ok('https://admin.kong-server.com/instance/register', 'POST', 401)
    self._assert_url_responds_ok('https://admin.kong-server.com/instance/renew', 'POST', 401)

  def _assert_url_responds_ok(self, url, http_verb = 'GET', expected_state = 200):
    print(f"Asserting that {url} with {http_verb} responds {expected_state}...")
    response = self.requests.request(http_verb, url, verify = False)
    if response.status_code != expected_state:
      print(f"The admin endpoint URL {url} is not available")
      raise Exception(f"Cannot continue setting up state because the endpoint {url} is not available")
