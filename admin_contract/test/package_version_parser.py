import re

class PackageVersionParser:
  def parse(self, package_version):
    package_version_parts = re.search('([0-9\.]+)~?([a-zA-Z0-9_]*)-?([a-z0-9]*)', package_version or '_empty_version_~_empty_branch_-_empty_commit_')
    return {
      'version': package_version_parts[1] or '_empty_version_',
      'branch_name': package_version_parts[2] or '_empty_branch_',
      'commit_sha1': package_version_parts[3] or '_empty_commit_'
    }
