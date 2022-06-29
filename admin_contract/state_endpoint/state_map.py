from live_states import InstanceNotExists, ServerIsAvailable
import requests

class StateMap:
  def __init__(self):
    self.map = {
      "the server is available to receive register requests": ServerIsAvailable,
      f"doesn\'t have devapp-sb0.local consumer registered": InstanceNotExists
    }

  def get(self, state):
    return self.map[state](requests, state)

  def has(self, state) -> bool:
    return state in self.map
