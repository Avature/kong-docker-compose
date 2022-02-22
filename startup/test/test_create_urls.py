import subprocess
from unittest import main, mock, TestCase
import os
import shutil
from pathlib import Path

from test.debugger import run_debugger

if (os.environ.get("ENABLE_DEBUGGER")):
  run_debugger()

class TestCreateUrls(TestCase):
  def setUp(self):
    self.test_path = "/nginx_startup/server_hosts/test/"
    os.environ["TARGET_URLS_CONF_DIR"] = self.test_path + "/"
    Path(self.test_path).mkdir(parents=True, exist_ok=True)

  def tearDown(self):
    shutil.rmtree(self.test_path)

  def test_files_not_exist(self):
    self.assertFileNotExists(self.test_path + "/admin-url.conf")
    self.assertFileNotExists(self.test_path + "/gateway-url.conf")
    self.assertFileNotExists(self.test_path + "/konga-url.conf")

  def test_run_create_urls(self):
    subprocess.call("/nginx_startup/server_hosts/create-urls.sh")
    adminUrlContent = self.read_file(self.test_path + "/admin-url.conf")
    gatewayUrlContent = self.read_file(self.test_path + "/gateway-url.conf")
    kongaUrlContent = self.read_file(self.test_path + "/konga-url.conf")
    self.assertEqual('server_name admin-sepa-test-host-for-testing;\n', adminUrlContent)
    self.assertEqual('server_name gateway-sepa-test-host-for-testing kong-gateway;\n', gatewayUrlContent)
    self.assertEqual('server_name konga-sepa-test-host-for-testing;\n', kongaUrlContent)

  def assertFileNotExists(self, filename):
    self.assertFalse(os.path.isfile(filename))

  def read_file(self, filename):
    with open(filename) as file_resource:
      contents = file_resource.read()
    return contents
