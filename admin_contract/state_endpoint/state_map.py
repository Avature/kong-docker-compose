from live_states import InstanceNotExists, ServerIsAvailable
import requests

class StateMap:
  def __init__(self):
    self.map = {
      'the server is available to receive register requests': ServerIsAvailable,
      f"doesn\'t have {InstanceNotExists.CONSUMER_NAME} consumer registered": InstanceNotExists
    }

  def get(self, state):
    return self.map[state](requests)

  def has(self, state) -> bool:
    return state in self.map
