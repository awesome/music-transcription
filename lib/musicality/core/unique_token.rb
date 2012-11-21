module Musicality
  # Makes unique string tokens
  # @author James Tunnell
  class UniqueToken
    # Make a unique string token of a given length.
    # @param [Fixnum] len The desired string token length.
    def self.make_unique_token len
      rand(36**len).to_s(36)
    end
  end
end