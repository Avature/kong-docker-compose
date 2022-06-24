from flask import Flask

app = Flask(__name__)

@app.route('/alive')
def provider_state_is_alive():
  return 'It\'s Alive!'

@app.route('/test')
def set_provider_state():
  return 'Setting state'

if __name__ == "__main__":
  print("Starting Pact Provider State Endpoint Server...")
  app.run(host='0.0.0.0', port=9281)
