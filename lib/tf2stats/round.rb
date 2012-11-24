# require './point_capture'

module Tf2Stats

  class Round
    attr_reader :captures, :stats, :start_time, :end_time, :winner

    include Winnable
    include TimeLimitable

    def initialize(start_time)
      @stats = Statistics.new
      @captures = []
      @start_time = start_time
    end

    def add_capture point_capture
      @stats.add_sub_stats point_capture.stats
      @captures << point_capture
    end

    def is_finished(end_time, team)
      @end_time = end_time
      @winner = team
    end

    def won_mid?
      return nil if @captures.empty?
      return @winner == @captures[0].winner
    end
  end
end