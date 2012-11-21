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
    attr_reader :captures, :stats, :start_time, :end_time, :winner

    include Winnable
    include TimeLimitable

    def initialize(start_time)
      @stats = Statistics.new
      @captures = []
      @start_time = start_time
    end

    # adds a capture to the round
    # @param  point_capture [PointCapture] the capture that belongs to the round
    def add_capture point_capture
      @stats.add_sub_stats point_capture.stats
      @captures << point_capture
    end

    def is_finished(end_time, team)
      @end_time = end_time
      @winner = team
    end

    # determines if the round winner also won the initial mid fight
    # @return [Boolean] true if round winner was also winner of the first Capture Point
    def won_mid?
      return nil if @captures.empty?
      return @winner == @captures[0].winner
    end
  end
end