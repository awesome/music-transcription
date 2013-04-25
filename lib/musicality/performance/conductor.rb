require 'spcore'

module Musicality

# The conductor reads a score, assigns score parts to performers, prepares the 
# performers to perform, and follows the score tempo as it directs the rendering
# of performance samples.
# 
# @author James Tunnell
# 
class Conductor

  attr_reader :sample_rate, :start_of_score, :end_of_score,
               :performers, :time_counter, :sample_counter
  
  # A new instance of Conductor.
  # @param [Arrangement] arrangement Used to prepare a performance. Contains the
  #                                  score and instrument configurations.
  # @param [Numeric] time_conversion_sample_rate The sample rate used in
  #                                              converting the score from
  #                                              a note base to a time base.
  # @param [Numeric] rendering_sample_rate The sample rate used in rendering
  #                                        samples.
  # @param [Hash] optional_args Hashed args that are not required. Valid keys
  #                             are :max_attack_time, :default_instrument_config,
  #                             and :plugin_dirs.
  def initialize arrangement, time_conversion_sample_rate, rendering_sample_rate, optional_args = {} #arrangement, sample_rate = DEFAULT_SAMPLE_RATE, max_attack_time = 0.15
    score = arrangement.score
    raise ArgumentError, "score contains no parts" if score.parts.empty?
    raise ArgumentError, "time_conversion_sample_rate is not a Numeric" unless time_conversion_sample_rate.is_a?(Numeric)
    raise ArgumentError, "time_conversion_sample_rate is less than 100.0" if time_conversion_sample_rate < 100.0
    
    ScoreCollator.collate_score!(score)
    parts = ScoreConverter.make_time_based_parts_from_score score, time_conversion_sample_rate
    
    @start_of_score = parts.values.inject(parts.values.first.start_offset) {|so_far, part| now = part.start_offset; (now < so_far) ? now : so_far }
    @end_of_score = parts.values.inject(parts.values.first.end_offset) {|so_far, part| now = part.end_offset; (now > so_far) ? now : so_far }
    
    opts = {
      :max_attack_time => 0.15,
      :plugin_dirs => [], # File.expand_path(File.dirname(__FILE__))
    }.merge optional_args
    
    max_attack_time = opts[:max_attack_time]
    
    opts[:plugin_dirs].each do |dir|
      puts "loading plugins from #{dir}"
      PLUGINS.load_plugins dir
    end
    
    raise ArgumentError, "rendering_sample_rate is not a Numeric" unless rendering_sample_rate.is_a?(Numeric)
    raise ArgumentError, "rendering_sample_rate is less than 100.0" if rendering_sample_rate < 100.0
    @sample_rate = rendering_sample_rate
    @sample_period = 1.0 / @sample_rate
    
    instruments = arrangement.make_instruments @sample_rate
    
    @performers = []
    parts.each do |part_id, part|
      raise ArgumentError, "instruments does not have key for part id #{part_id}" unless instruments.has_key?(part_id)
      @performers << Performer.new(part, instruments[part_id], max_attack_time)
    end
    
    @time_counter = 0.0
    @sample_counter = 0
  end
  
  # Prepare to perform the score (at start of score). Gives the conductor a
  # chance to set up counters, and for performers to figure which notes will be
  # played. Must be called before any calls to perform_xxx.
  def prepare_performance
    prepare_performance_at @start_of_score
  end
  
  # Prepare to perform the score (at given start time). Gives the conductor a
  # chance to set up counters, and for performers to figure which notes will be
  # played. Must be called before any calls to perform_xxx.
  def prepare_performance_at start_time = 0.0
    @time_counter = start_time
    @sample_counter = (@time_counter * @sample_period).to_i
    @prepared_at_sample = @sample_counter
    
    @performers.each do |performer|
      performer.prepare_performance_at @time_counter
    end
  end

  # Perform the entire score, including given lead out time. If performance has not
  # already been prepared, it will be prepared for start of score.
  # @param [Numeric] lead_out_time The amount of time to go past the end of the
  #                                score during performance.
  def perform lead_out_time = 0.0
    if @sample_counter != @prepared_at_sample
      prepare_performance
    end
    
    samples = []

    while @time_counter < (@end_of_score + lead_out_time) do
      samples << perform_sample
    end

    if block_given?
      yield samples
    end
    
    @prepared_at_sample = @sample_counter
    return samples
  end
  
  # Perform score for the given duration in seconds. If performance has not
  # already been prepared, it will be prepared for start of score.
  # @param [Numeric] time_sec
  def perform_seconds time_sec
    if @sample_counter != @prepared_at_sample
      prepare_performance
    end
    
    n_samples = time_sec / @sample_period
    samples = []

    n_samples.to_i.times do
      samples << perform_sample
    end
    
    if block_given?
      yield samples
    end
    
    @prepared_at_sample = @sample_counter
    return samples
  end

  # Perform score for the given number of samples. If performance has not
  # already been prepared, it will be prepared for start of score.
  # @param [Numeric] n_samples The number of samples of the score to render.
  def perform_samples n_samples
    if @sample_counter != @prepared_at_sample
      prepare_performance
    end
    
    samples = []
    
    n_samples.times do
      samples << perform_sample
    end
    
    if block_given?
      yield samples
    end
    
    @prepared_at_sample = @sample_counter    
    return samples
  end
  
  private
  
  # Render an audio sample of the performance at the current note counter.
  # Increments the note counter by the current notes per sample (computed from 
  # current tempo). Increments the sample counter by 1 and the time counter by 
  # the sample period.
  def perform_sample
    sample = 0.0

    if @time_counter <= @end_of_score
      @performers.each do |performer|
        sample += performer.perform_sample(@time_counter)
      end
    end
    
    @time_counter += @sample_period
    @sample_counter += 1

    if block_given?
      yield sample
    end
    
    return sample
  end

end

end

