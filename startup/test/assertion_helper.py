import json
import responses

class AssertionHelper():
  def __init__(self, test):
    self.test = test

  def assert_upsert_call(self, expected_body, call_number=9):
    self.test.assertEqual(
      json.loads(responses.calls[call_number].request.body),
      expected_body
    )

  def assert_call_count(self, path, call_count):
    self.test.assertTrue(responses.assert_call_count(f'http://kong:8001/{path}', call_count))
