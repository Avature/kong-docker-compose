from unittest import TestCase
import os
import responses
from fixture import Fixture

from test.debugger import run_debugger

if (os.environ.get("ENABLE_DEBUGGER")):
  run_debugger()

class TestFixture(TestCase):
  def setUp(self):
    self.subject = Fixture()

  @responses.activate
  def test_run_create_all_succeed(self):
    responses.add(responses.GET, 'http://kong:8001/consumers/admin/key-auth', status=404)
    responses.add(responses.POST, 'http://kong:8001/consumers', status=201)
    responses.add(responses.POST, 'http://kong:8001/consumers/admin/key-auth', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/routes/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/routes', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/routes/adminApiRegisterInstance', status=404)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/routes/adminApiRenewInstance', status=404)
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/routes', status=201)
    responses.add(responses.GET, 'http://kong:8001/routes/adminApi/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApi/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/services/adminApi/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/services/adminApi/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/routes/adminApiRegisterInstance/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApiRegisterInstance/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/routes/adminApiRenewInstance/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/routes/adminApiRenewInstance/plugins', status=201)
    responses.add(responses.GET, 'http://kong:8001/plugins', status=200, json={"data":[]})
    responses.add(responses.POST, 'http://kong:8001/plugins', status=201)
    self.subject.run()
    self.assertTrue(responses.assert_call_count('http://kong:8001/routes/adminApi/plugins', 3))
    self.assertTrue(responses.assert_call_count('http://kong:8001/routes/adminApiRegisterInstance/plugins', 2))
    self.assertTrue(responses.assert_call_count('http://kong:8001/routes/adminApiRenewInstance/plugins', 4))
    self.assertTrue(responses.assert_call_count('http://kong:8001/services/adminApi/plugins', 2))

  def test_get_admin_plugins(self):
    result = self.subject.get_admin_plugins()
    self.assertEqual(len(result), 8)

  @responses.activate
  def test_create_admin_service_and_failed(self):
    responses.add(responses.GET, 'http://kong:8001/services/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services', status=404)
    with self.assertRaises(SystemExit):
      self.subject.create_admin_service()
    self.assertEqual(responses.calls[1].request.body, 'name=adminApi&protocol=http&port=8001&host=127.0.0.1')

  @responses.activate
  def test_create_admin_service_and_success(self):
    responses.add(responses.GET, 'http://kong:8001/services/adminApi', status=404)
    responses.add(responses.POST, 'http://kong:8001/services', status=201)
    self.subject.create_admin_service()
    self.assertEqual(responses.calls[1].request.body, 'name=adminApi&protocol=http&port=8001&host=127.0.0.1')
