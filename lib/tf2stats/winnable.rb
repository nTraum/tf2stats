module Tf2Stats
  module Winnable


    # returns true if team BLU won
    #
    # @return [Boolean] true if team BLU won, false if not
    def won_blu?
      :blu == winner
    end

    # returns true if team RED won
    #
    # @return [Boolean] true if team RED won, false if not
    def won_red?
      :red == winner
    end

    # returns true if team BLU lost
    #
    # @return [Boolean] true if team BLU lost, false if not
    def lost_blu?
      :blu == winner
    end

    # returns true if team RED lost
    #
    # @return [Boolean] true if team RED lost, false if not
    def lost_red?
      :red == winner
    end

    # returns true if neither team BLU nor team RED won
    #
    # @return [Boolean] true if neither team BLU nor team RED won
    def stalemate?
      winner.nil?
    end
  end
end