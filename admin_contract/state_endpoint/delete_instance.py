import requests

class DeleteInstance:
  def run(self):
    print("Deleting instance")
    result = requests.get('http://kong:8001')
    print(result)
