import sys
from unittest import main, mock, TestCase
import os
import configparser

class FixtureTest(TestCase):
  def test_create_admin(self):
    mock_config_parser = configparser.ConfigParser()
    mock_os = mock.Mock()
    mock_requests = mock.Mock()
    mock_config_parser["kong-apikey"] = {"apikey":"testing_api_key"}
    mock_config_parser.read = mock.MagicMock()
    mock_response = mock.Mock()
    mock_response.status_code = 201
    mock_requests.get = mock.MagicMock()
    mock_requests.post = mock.MagicMock(return_value=mock_response)
    mock_config_parser.ConfigParser = mock.MagicMock(return_value=mock_config_parser)
    mock_os.environ = {"kong_apikey_file": "secrets.ini"};
    sys.modules['configparser'] = mock_config_parser
    sys.modules['os'] = mock_os
    sys.modules['requests'] = mock_requests

    from fixture import Fixture

    subject = Fixture()
    subject.run()

