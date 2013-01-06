module Musicality
# Contains time-based parts, and a map of instruments to part IDs, and a map
# of effects to part IDs.
#
# @author James Tunnell
class Arrangement
  attr_reader :parts, :instruments, :start, :end
  
  # New instance of Arrangement
  #
  # @param [Hash] parts Hash that maps part IDs to Part objects. Parts should be
  #                      collated and time-based (i.e., score should pass
  #                      through score collator and time converter first, and
  #                      each part's note sequences should pass through the
  #                      note sequence combiner).
  # @param [Hash] instruments Hash that maps part IDs to PluginConfig objects
  #                           (used to create instruments)
  def initialize parts, instruments
    @start = parts.values.inject(parts.values.first.find_start) {|so_far, part| now = part.find_start; (now < so_far) ? now : so_far }
    @end = parts.values.inject(parts.values.first.find_end) {|so_far, part| now = part.find_end; (now > so_far) ? now : so_far }
    
    @parts = parts
    @instruments = instruments
  end
  
end
end