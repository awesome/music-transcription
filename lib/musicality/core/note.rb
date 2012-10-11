module Musicality

# Abstraction of a musical note. Contains values for pitch, duration, intensity, loudness, and seperation.
# The loudness, intensity, and seperation will be used to form the envelope profile for the note.
#
# @author James Tunnell
# 
# @!attribute [rw] pitch
#   @return [Pitch] The pitch of the note.
#
# @!attribute [rw] duration
#   @return [Rational] the duration of the note, in note lengths (e.g. 
#                      whole note => 1/1, quarter note => 1/4).
#
# @!attribute [rw] intensity
#   @return [Float] Affects the loudness (envelope) during the attack 
#                   portion of the note. From 0.0 (less attack) to 1.0 
#                   (more attack).
#
# @!attribute [rw] loudness
#   @return [Float] Affects the loudness (envelope) during the sustain 
#                   portion of the note. From 0.0 (less sustain) to 1.0 
#                   (more sustain).
#
# @!attribute [rw] seperation
#   @return [Float] Shift the note release towards or away the beginning
#                   of the note. From 0.0 (towards end of the note) to 
#                   1.0 (towards beginning of the note).
#
# @!attribute [rw] tie
#   @return [true/false] Indicates the note should be played 
#                        continuously with the following note of the 
#                        same pitch (if such a note exists).
#
# @!attribute [rw] slur
#   @return [true/false] Indicates the following note (if such a note 
#                        exists) should be played without rearticulation
#                        (i.e. no attack).
#
class Note

  attr_reader :pitch, :duration, :loudness, :intensity, :seperation
  attr_accessor :tie, :slur
  
  # A new instance of Note.
  # @param [Pitch] pitch The pitch of the note.
  # @param [Rational] duration The duration of the note, in note lengths
  #                   (e.g. whole note => 1/1, quarter note => 1/4).
  # @param [Hash] options Optional arguments. Valid keys are :loudness,
  #               :intensity, :seperation, :tie, and :slur.
  def initialize pitch, duration, options={}
    self.pitch = pitch
    self.duration = duration
  
    opts = {
      :loudness => 0.5,
      :intensity => 0.5,
      :seperation => 0.5,
      :tie => false,
      :slur => false,
    }.merge options
	  
    # The loudness, intensity, and seperation will be used to form the envelope profile for the note.

    self.loudness = opts[:loudness]
    self.intensity = opts[:intensity]	
	self.seperation = opts[:seperation]
    self.tie = opts[:tie]
    self.slur = opts[:slur]
  end
  
  # Set the note pitch.
  # @param [Pitch] pitch The pitch of the note.
  # @raise [ArgumentError] if pitch is not a Pitch.
  def pitch= pitch
    raise ArgumentError, "pitch is not a Pitch" if !pitch.is_a?(Pitch)
    @pitch = pitch
  end

  # Set the note duration.
  # @param [Rational] duration The duration of the note.
  # @raise [ArgumentError] if duration is not a Rational.
  def duration= duration
  	raise ArgumentError, "duration is not a Rational" if !duration.is_a?(Rational)    
  	@duration = duration
  end

  # Set the note loudness.
  # @param [Float] loudness The loudness of the note.
  # @raise [ArgumentError] if loudness is not a Float.
  # @raise [RangeError] if loudness is outside the range 0.0..1.0.
  def loudness= loudness
    raise ArgumentError, "loudness is not a Float" if !loudness.is_a?(Float)
    raise RangeError, "loudness is outside the range 0.0..1.0" if !(0.0..1.0).include?(loudness)
  	@loudness = loudness
  end

  # Set the note intensity.
  # @param [Float] intensity The intensity of the note.
  # @raise [ArgumentError] if intensity is not a Float.
  # @raise [RangeError] if intensity is outside the range 0.0..1.0.
  def intensity= intensity
    raise ArgumentError, "intensity is not a Float" if !intensity.is_a?(Float)
    raise RangeError, "intensity is outside the range 0.0..1.0" if !(0.0..1.0).include?(intensity)
	@intensity = intensity
  end

  # Set the note seperation.
  # @param [Float] seperation The seperation of the note.
  # @raise [ArgumentError] if seperation is not a Float.
  # @raise [RangeError] if seperation is outside the range 0.0..1.0.
  def seperation= seperation
    raise ArgumentError, "seperation is not a Float" if !seperation.is_a?(Float)
    raise RangeError, "seperation is outside the range 0.0..1.0" if !(0.0..1.0).include?(seperation)
    @seperation = seperation
  end
end

end
