from flask import Flask, request
from state_processor import StateProcessor

app = Flask(__name__)

@app.route('/alive')
def provider_state_is_alive():
  return 'It\'s Alive!'

@app.route('/provider_states', methods=['POST'])
def set_provider_state():
  state_data = request.json
  state_processor = StateProcessor()
  state_processor.process(state_data['state'])
  return 'Setting state'

if __name__ == "__main__":
  print("Starting Pact Provider State Endpoint Server...")
  app.run(host='0.0.0.0', port=9281)
