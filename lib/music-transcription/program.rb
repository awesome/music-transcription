module Music
module Transcription

# Program defines markers (by starting note offset) and subprograms (list which markers are played).
#
# @author James Tunnell
#
class Program
  attr_accessor :segments

  # A new instance of Program.
  # @param [Hash] args Hashed arguments. Required key is :segments.
  def initialize segments = []
    @segments = segments
  end

  # @return [Float] the sum of all program segment lengths
  def length
    segments.inject(0.0) { |length, segment| length + (segment.last - segment.first) }
  end
  
    # compare to another Program
  def == other
#    raise ArgumentError, "program is invalid" if !self.valid?    
    return @segments == other.segments
  end

  def include? offset
    @segments.each do |segment|
      if segment.include?(offset)
        return true
      end
    end
    return false
  end

  # For the given note elapsed, what will the note offset be?
  #
  def note_offset_for elapsed
    raise ArgumentError, "elapsed #{elapsed} is less than 0.0" if elapsed < 0.0
    raise ArgumentError, "elapsed #{elapsed} is greater than program length" if elapsed > self.length
    
    so_far = 0.0
    
    @segments.each do |segment|
      segment_length = segment.last - segment.first
      
      if (segment_length + so_far) > elapsed
        return segment.first + (elapsed - so_far)
      else
        so_far += segment_length
      end
    end
    
    raise "offset not determined even though the given elapsed is less than program length!"
  end
  
  # For the given note offset in the score, how much note will have elapsed to 
  # get there according to the program?
  #
  def note_elapsed_at offset
    raise ArgumentError, "offset #{offset} is not included in program" if !self.include?(offset)
    
    elapsed = 0.0
    
    @segments.each do |segment|
      if segment.include?(offset)
        elapsed += (offset - segment.first)
        break
      else
        elapsed += (segment.last - segment.first)
      end
    end
    
    return elapsed
  end
  
  # For the given note offset in the score, how much time will have elapsed to 
  # get there according to the program?
  #
  def time_elapsed_at offset, note_time_converter
    raise ArgumentError, "offset #{offset} is not included in program" if !self.include?(offset)

    elapsed = 0.0
    
    @segments.each do |segment|
      if segment.include?(offset)
        elapsed += note_time_converter.time_elapsed(segment.first, offset)
        break
      else
        elapsed += note_time_converter.time_elapsed(segment.first, segment.last)
      end
    end
    
    return elapsed
  end
  
end

module_function

def program segments
  Program.new(:segments => segments)
end

end
end
