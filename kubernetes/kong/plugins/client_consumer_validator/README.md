# Client Consumer Validator Kong Plugin

This plugin executes some assertions over the client's requests data (json payload) and headers to assure the activity does not include bad intentions such as leaking data or parasitic redirection of an API flow.

It can compare headers and json payload paths with the client's associated consumer's username.

## Run the tests:

To run the test in docker execute the following bash script:

./run_tests_with_docker.sh
