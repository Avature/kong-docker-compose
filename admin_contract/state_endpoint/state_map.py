from delete_instance import DeleteInstance

class StateMap:
  def __init__(self):
    self.map = {
      'The instance does not exists': DeleteInstance
    }

  def get(self, state):
    return self.map[state]()
