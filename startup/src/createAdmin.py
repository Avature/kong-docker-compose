from fixture import Fixture
from config import Config
from pluginsComparator import PluginsComparator

fixture = Fixture(Config(), PluginsComparator())
fixture.run()
