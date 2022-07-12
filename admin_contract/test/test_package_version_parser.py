from unittest import TestCase

from .package_version_parser import PackageVersionParser

class TestPackageVersionParser(TestCase):
  def setUp(self):
    self.subject = PackageVersionParser()

  def test_package_version_with_all_params(self):
    result = self.subject.parse('0.0.1~master-690fbb44')
    self.assertEqual('0.0.1', result['version'])
    self.assertEqual('master', result['branch_name'])
    self.assertEqual('690fbb44', result['commit_sha1'])

  def test_package_version_only_with_version(self):
    result = self.subject.parse('0.0.21')
    self.assertEqual('0.0.21', result['version'])
    self.assertEqual('_empty_branch_', result['branch_name'])
    self.assertEqual('_empty_commit_', result['commit_sha1'])
