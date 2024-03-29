class PluginsComparator:
  def plugin_has_different_config(self, current_config, plugin_expected_config):
    config_fields = plugin_expected_config['config'] if 'config' in plugin_expected_config else {}
    clean_current_config = self._clean_null_config_values(current_config['config'], config_fields)
    return config_fields != clean_current_config or self._is_enabled_defined_and_differs(plugin_expected_config, current_config)

  def _is_enabled_defined_and_differs(self, plugin_expected_config, current_config):
    return ("enabled" in plugin_expected_config) and (
      plugin_expected_config['enabled'] != self._currently_enabled(current_config)
    )

  def _currently_enabled(self, current_config):
    return current_config['enabled'] if 'enabled' in current_config else None

  def _clean_null_config_values(self, config, mask):
    clean = {}
    for k, v in config.items():
        if isinstance(v, dict) and k in mask:
          nested = self._clean_null_config_values(v, mask[k])
          if len(nested.keys()) > 0:
              clean[k] = nested
        elif v is not None and k in mask:
          clean[k] = v
    return clean
