class BaseState:
  DIRECT_ADMIN_HOST = 'http://kong-direct-admin:8001'

  def __init__(self, requests, state_statement):
    self.requests = requests
    self.state_statement = state_statement

  def apply(self):
    raise Exception('apply method should be implemented on a child class')
