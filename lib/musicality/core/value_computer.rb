module Musicality

# Compute the value of a SettingProfile for any offset.
# @author James Tunnell
#
# @!attribute [r] piecewise_function
#   @return [PiecewiseFunction] A piecewise function that can calculate the 
#                               value for any valid offset.
#
class ValueComputer
  attr_reader :piecewise_function

  def initialize setting_profile
    @piecewise_function = Musicality::PiecewiseFunction.new
    set_default_value setting_profile.start_value
    
    if setting_profile.value_changes.any?
      value_changes = setting_profile.value_changes.sort_by {|a| a.offset }
        
      value_changes.each do |event|
        case event.transition.type
        when Transition::IMMEDIATE
          add_immediate_value_change event
        when Transition::LINEAR
          add_linear_value_change event
        when Transition::SIGMOID
          add_sigmoid_value_change event
        end
        
      end
    end
  end

  # Compute the value at the given offset.
  # @param [Numeric] offset The given offset to compute value at.
  def value_at offset
    @piecewise_function.evaluate_at offset
  end
  
  # finds the minimum domain value
  def domain_min
    ValueChange::MIN_OFFSET
  end

  # finds the maximum domain value
  def domain_max
    ValueChange::MAX_OFFSET
  end
  
  # finds the minimum domain value
  def self.domain_min
    ValueChange::MIN_OFFSET
  end

  # finds the maximum domain value
  def self.domain_max
    ValueChange::MAX_OFFSET
  end
  
  private

  def set_default_value value
    func = lambda {|x| value }
    @piecewise_function.add_piece( domain_min...(domain_max + 1), func )
  end

  # Add a function piece to the piecewise function, which will to compute value
  # for a matching note offset. Transition duration will be ignored since the
  # change is immediate.
  #
  # @param [Numeric] value_change An event with information about the new value.
  def add_immediate_value_change value_change
    func = nil
    offset = value_change.offset
    value = value_change.value
    duration = value_change.transition.duration
    domain = offset...(domain_max + 1)
    func = lambda {|x| value }
    
    @piecewise_function.add_piece domain, func
  end
    
  # Add a function piece to the piecewise function, which will to compute value
  # for a matching note offset. If the dynamic event duration is non-zero, a 
  # linear transition function is created.
  #
  # @param [Numeric] value_change An event with information about the new value.
  def add_linear_value_change value_change
    
    func = nil
    offset = value_change.offset
    value = value_change.value
    duration = value_change.transition.duration
    domain = offset...(domain_max + 1)
    
    if duration == 0
      func = lambda {|x| value }
    else
      b = @piecewise_function.evaluate_at domain.first
      m = (value - b) / duration
      
      func = lambda do |x|
        raise RangeError, "#{x} is not in the domain" if !domain.include?(x)
        
        if x < (domain.first + duration)
          (m * (x - domain.first)) + b
        else
          value
        end
      end
    end
    
    @piecewise_function.add_piece domain, func
  end

  # Add a function piece to the piecewise function, which will to compute value
  # for a matching note offset. If the dynamic event duration is non-zero, a 
  # linear transition function is created.
  #
  # @param [Numeric] value_change An event with information about the new value.
  def add_sigmoid_value_change value_change
    
    func = nil
    offset = value_change.offset
    value = value_change.value
    duration = value_change.duration
    domain = offset...(domain_max + 1)
    
    if duration == 0
      func = lambda {|x| value }
    else
      # TODO - replace with sigmoid-like function
      
      #b = @piecewise_function.evaluate_at domain.first
      #m = (value - b) / duration
      #
      #func = lambda do |x|
      #  raise RangeError, "#{x} is not in the domain" if !domain.include?(x)
      #  
      #  if x < (domain.first + duration)
      #    (m * (x - domain.first)) + b
      #  else
      #    value
      #  end
      #end
    end
    
    @piecewise_function.add_piece domain, func
  end

end

end
