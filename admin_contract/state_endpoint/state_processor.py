from typing import List
from state_map import StateMap

class StateProcessor:
  def process(self, state_data):
    map = StateMap()
    states = self.get_states(state_data)
    for state in states:
      if (not map.has(state)):
        raise Exception(f"The known action-map does not have the desired target state: {state}")
      live_state = map.get(state)
      live_state.apply()

  def get_states(self, state_data: str) -> List[str]:
    return state_data.lower().split(' and ')
