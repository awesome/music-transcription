module Musicality

# Abstraction of a musical pitch. Contains values for octave, semitone, 
# and cent. These values are useful because they allow simple mapping to
# both the abstract (musical scales) and concrete (audio data).
#
# Fundamentally, pitch can be considered a ratio to some base number. 
# For music, this is a base frequency. The pitch frequency can be 
# determined by multiplying the base frequency by the pitch ratio. For 
# the standard musical scale, the base frequency of C0 is 16.35 Hz.
# 
# Octaves represent the largest means of differing two pitches. Each 
# octave added will double the ratio. At zero octaves, the ratio is 
# 1.0. At one octave, the ratio will be 2.0. Each semitone and cent 
# is an increment of less-than-power-of-two.
#
# Semitones are the primary steps between octaves. By default, the 
# number of semitones per octave is 12, corresponding to the twelve-tone equal 
# temperment tuning system. The number of semitones per octave can be 
# modified at runtime by overriding the Pitch::SEMITONES_PER_OCTAVE 
# constant.
#
# Cents are the smallest means of differing two pitches. By default, the 
# number of cents per semitone is 100 (hence the name cent, as in per-
# cent). This number can be modified at runtime by overriding the 
# Pitch::CENTS_PER_SEMITONE constant.
#
# @author James Tunnell
# 
# @!attribute [r] octave
#   @return [Fixnum] The pitch octave.
# @!attribute [r] semitone
#   @return [Fixnum] The pitch semitone.
# @!attribute [r] cent
#   @return [Fixnum] The pitch cent.
# @!attribute [r] cents_per_octave
#   @return [Fixnum] The number of cents per octave. Default is 1200 
#    				 (12 x 100). If a different scale is required, 
#                    modify CENTS_PER_SEMITONE (default 12) and/or 
#                    SEMITONES_PER_OCTAVE (default 100).
# @!attribute [r] base_freq
#   @return [Float] Multiplied with pitch ratio to determine the final frequency
#                   of the pitch. Defaults to DEFAULT_BASE_FREQ, but can be set 
#                   during initialization to something else using the :base_freq key.
#
class Pitch
  include Comparable
  include HashMake
  attr_accessor :octave, :semitone, :cent, :base_freq
  attr_reader :cents_per_octave

  #The default number of semitones per octave is 12, corresponding to 
  # the twelve-tone equal temperment tuning system.
  SEMITONES_PER_OCTAVE = 12

  #The default number of cents per semitone is 100 (hence the name cent,
  # as in percent).
  CENTS_PER_SEMITONE = 100
  
  # The default base ferquency is C0
  DEFAULT_BASE_FREQ = 16.351597831287414

  # required hash-args (for hash-makeable idiom)
  REQ_ARGS = [ ]
  # optional hash-args (for hash-makeable idiom)
  OPT_ARGS = [ spec_arg(:octave, Numeric, ->(a){ true}, 0),
               spec_arg(:semitone, Numeric, ->(a){ true}, 0), 
               spec_arg(:cent, Numeric, ->(a){ true}, 0), 
               spec_arg(:base_freq, Numeric, ->(a){ a > 0.0 }, DEFAULT_BASE_FREQ) ]  
  
  # A new instance of Pitch.
  # @param [Hash] args Hashed args. Valid, optional keys are :octave, 
  #                    :semitone, :cent, :total_cent, and :ratio.
  #                    When :total_cent is set, it will override all 
  #                    other arguments.
  #                    When :ratio is set, it will override all other
  #                    arguments except :total_cent.
  #                    Otherwise, when :octave, :semitone, and :cent 
  #                    are set, each will override the default of zero.
  # @raise [ArgumentError] if any of :octave, :semitone, or :cent is
  #                        not a Fixnum.
  def initialize args={}
    @cents_per_octave = CENTS_PER_SEMITONE * SEMITONES_PER_OCTAVE
    process_args args
  end

  def freq
    return self.ratio() * @base_freq
  end

  # Return the pitch's frequency, which is determined by multiplying the base 
  # frequency and the pitch ratio. Base frequency defaults to DEFAULT_BASE_FREQ,
  # but can be set during initialization to something else by specifying the 
  # :base_freq key.
  def freq
    return self.ratio() * @base_freq
  end
  
  # Set the pitch according to the given frequency. Uses the current base_freq 
  # to determine what the pitch ratio should be, and sets it accordingly.
  def freq= freq
    self.ratio = freq / @base_freq
  end

  # Calculate the total cent count. Converts octave and semitone count
  # to cent count before adding to existing cent count.
  # @return [Fixnum] total cent count
  def total_cent
    return (@octave * @cents_per_octave) +
            (@semitone * CENTS_PER_SEMITONE) + @cent
  end
  
  # Set the Pitch ratio according to a total number of cents.
  # @param [Fixnum] cent The total number of cents to use.
  # @raise [ArgumentError] if cent is not a Fixnum
  def total_cent= cent
    raise ArgumentError, "cent is not a Fixnum" if !cent.is_a?(Fixnum)
    @octave, @semitone, @cent = 0, 0, cent
    normalize
  end

  # Calculate the pitch ratio. Raises 2 to the power of the total cent 
  # count divided by cents-per-octave.
  # @return [Float] ratio
  def ratio
    2.0**(self.total_cent.to_f / @cents_per_octave)
  end

  # Represent the Pitch ratio according to a ratio.
  # @param [Numeric] ratio The ratio to represent.
  # @raise [RangeError] if ratio is less than or equal to 0.0
  def ratio= ratio
    raise RangeError, "ratio #{ratio} is less than or equal to 0.0" if ratio <= 0.0
    
    x = Math.log2 ratio
    self.total_cent = (x * @cents_per_octave).round
  end

  # Round to the nearest semitone.
  def round_to_nearest_semitone
    if @cent >= (CENTS_PER_SEMITONE / 2)
      @semitone += 1
    end
    @cent = 0
    normalize
  end
  
  def total_semitone
    return (@octave * SEMITONES_PER_OCTAVE) + @semitone
  end
  
  # Compare pitches. A higher ratio or total cent is considered larger.
  # @param [Pitch] other The pitch object to compare.
  def <=> (other)
    self.total_cent <=> other.total_cent
  end

  # Add pitches by adding the total cent count of each.
  # @param [Pitch] other The pitch object to add. 
  def + (other)
    self.class.new :octave => (@octave + other.octave), :semitone => (@semitone + other.semitone), :cent => (@cent + other.cent)
  end

  # Add pitches by subtracting the total cent count.
  # @param [Pitch] other The pitch object to subtract.
  def - (other)
    self.class.new :octave => (@octave - other.octave), :semitone => (@semitone - other.semitone), :cent => (@cent - other.cent)
  end
  
  def clone
    Pitch.new(:octave => @octave, :semitone => @semitone, :cent => @cent, :base_freq => @base_freq)
  end
  
  private
  
  # Balance out the octave, semitone, and cent count. 
  def normalize
    centTotal = (@octave * @cents_per_octave) + (@semitone * CENTS_PER_SEMITONE) + @cent
    
    @octave = centTotal / @cents_per_octave
    centTotal -= @octave * @cents_per_octave
    
    @semitone = centTotal / CENTS_PER_SEMITONE
    centTotal -= @semitone * CENTS_PER_SEMITONE
    
    @cent = centTotal
    return true
  end
  
end
end