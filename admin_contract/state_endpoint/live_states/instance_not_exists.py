import re
from .base_state import BaseState

class InstanceNotExists(BaseState):
  def apply(self):
    self._make_sure_consumer_not_exists(
      self._get_instance_name()
    )

  def _make_sure_consumer_not_exists(self, consumer_name):
    consumer_response = self.requests.get(f"{InstanceNotExists.DIRECT_ADMIN_HOST}/consumers/{consumer_name}")
    if consumer_response.status_code == 404:
      print(f"Instance consumer {consumer_name} does not exists")
      return
    print(f"Instance was found, deleting {consumer_name}")
    response_deleting = self.requests.delete(f"{InstanceNotExists.DIRECT_ADMIN_HOST}/consumers/{consumer_name}")
    if response_deleting.status_code != 204:
      raise Exception(f"Error deleting the instance {consumer_name}")

  def _get_instance_name(self):
    regex_search = re.search("doesn\\'t\shave\s(.+)\sconsumer registered", self.state_statement)
    return regex_search[1]
