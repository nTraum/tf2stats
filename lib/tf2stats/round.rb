# require './point_capture'

module Tf2Stats

  # Represents a round in a TF2 Match
  #@!attribute [r] captures
  #   @return [Array<PointCapture>] list of captures happened in this round
  #@!attribute [r] stats
  #   @return [Statistics] statistics of this round
  #@!attribute start_time
  #   @return [Fixnum] time of round start in seconds, relative to match begin
  #@!attribute end_time
  #   @return [Fixnum] time of round end in seconds, relative to match begin
  #@!attribute winner
  #   @return [Symbol, nil] winner of the round, either nil, :blu or :red
  class Round
    attr_reader :captures, :stats
    attr_accessor :start_time, :end_time, :winner

    include Winnable

    def initialize
      @stats = Statistics.new
      @captures = []
    end

    # adds a capture to the round
    # @param  point_capture [PointCapture] the capture that belongs to the round
    def add_capture point_capture
      @stats.add_sub_stats point_capture.stats
      @captures << point_capture
    end

    # determines if the round winner also won the initial mid fight
    # @return [Boolean] true if round winner was also winner of the first Capture Point
    def won_mid?
      return nil if @captures.empty?
      return @winner == @captures[0].winner
    end


    # number of captures in this round
    # @return [Fixnum] number of captures happened in this round
    def captures_count
      @captures.size
    end

    # duration of the round in seconds
    # @return [Fixnum] duration of the round in seconds
    def duration
      @end_time - @start_time
    end
  end
end