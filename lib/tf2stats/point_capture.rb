module Tf2Stats
  class PointCapture
    attr_reader :stats
    attr_accessor :start_time, :end_time, :winner, :number, :name

    def initialize
      @stats = Statistics.new
    end

    def duration
      @end_time - @start_time
    end

    # determines if team BLU won this cp
    # @return [Boolean] true if team BLU won this cp
    def won_blu?
      :blu == @winner
    end

    # determines if team RED won this cp
    # @return [Boolean] true if team RED won this cp
    def won_red?
      :red == @winner
    end

    # determines if this cp ended in a tie
    # @return [Boolean] true if none of both teams won
    def stalemate?
      @winner.nil?
    end
  end
end