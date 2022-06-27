from flask import Flask, request
from state_map import StateMap

app = Flask(__name__)

@app.route('/alive')
def provider_state_is_alive():
  return 'It\'s Alive!'

@app.route('/provider_states', methods=['POST'])
def set_provider_state():
  state_data = request.json
  map = StateMap()
  live_state = map.get(state_data['state'])
  live_state.apply()
  return 'Setting state'

if __name__ == "__main__":
  print("Starting Pact Provider State Endpoint Server...")
  app.run(host='0.0.0.0', port=9281)
