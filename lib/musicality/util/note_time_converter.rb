module Musicality

class NoteTimeConverter

  def initialize tempo_computer, sample_rate
    @tempo_computer = tempo_computer
    @sample_period = 1.0 / sample_rate
  end
  
  def time_elapsed note_begin, note_end
    raise ArgumentError "note end is less than note begin" if note_end < note_begin
    
    time = 0.0
    note = note_begin
    
    while note < note_end
      notes_per_sec = @tempo_computer.notes_per_second_at note
      notes_per_sample = notes_per_sec * @sample_period
      
      if (note + notes_per_sample) > note_end
        #interpolate between note and note_end
        perc = (note_end - note) / notes_per_sample
        time += @sample_period * perc
        note = note_end
      else
        time += @sample_period
        note += notes_per_sample
      end

    end
    
    return time
  end

end

end