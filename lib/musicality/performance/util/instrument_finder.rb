module Musicality
require 'spcore'

# Responsible for find an instrument plugin for each part in a score.
#
# @author James Tunnell
class InstrumentFinder
    
  # Find an instrument to use for each part. Uses assigned instrument if
  # it can be found, or the default instrument if none is assigned or
  # if the assigned can't be found.
  # 
  # @param [Score] score The score to be used to make an Arrangement.
  # @param [Array] plugin_dirs A list of directories to load plugins from.
  # @param [PluginConfig] default_instrument_config (optional) The instrument
  #                                                 plugin config to use if one
  #                                                 is not assigned to the part
  #                                                 or if the one assigned can't
  #                                                 be found.
  def self.find_instruments score, plugin_dirs, default_instrument_config

    plugin_dirs.each do |dir|
      puts "loading plugins from #{dir}"
      PLUGINS.load_plugins dir
    end
    
    unless PLUGINS.plugins.has_key?(default_instrument_config.plugin_name.to_sym)
      raise ArgumentError, "default instrument plugin #{default_instrument_config.plugin_name} is not registered"
    end
    
    instruments = {}
    score.parts.each do |id, part|
      instruments[id] = Marshal.load(Marshal.dump(default_instrument_config)) # deep copy, in case it's modified
    
    #  TODO - score should contain a map of part ID to instrument/effet configs. Check there instead of in each part...
    #
    #  part.instrument_plugins.keep_if { |plugin| PLUGINS.plugins.has_key? plugin.plugin_name.to_sym }
    #  
    #  if part.instrument_plugins.empty?
    #    part.instrument_plugins << @default_instrument_plugin
    #  end
    #  
    #  part.effect_plugins.keep_if { |plugin| PLUGINS.plugins.has_key? plugin.plugin_name.to_sym }
    #
    end
    
    instruments
  end
  
end
end