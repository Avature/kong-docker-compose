import requests

class DeleteInstance:
  def apply(self):
    print("Deleting instance")
    result = requests.delete('http://kong-direct-admin:8001/consumers/devapp-sb0.local')
    print(result)
