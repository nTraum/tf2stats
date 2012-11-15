# require './point_capture'

module Tf2Stats
  class Round
    attr_reader :captures, :stats
    attr_accessor :start_time, :end_time, :winner

    def initialize
      @stats = Statistics.new
      @captures = []
    end

    def add_capture point_capture
      @stats.add_sub_stats point_capture.stats
      @captures << point_capture
    end

    def won_blu?
      :blu == @winner
    end

    def won_red?
      :red == @winner
    end

    def stalemate?
      @winner.nil?
    end

    def won_mid?
      return nil if @captures.empty?
      return @winner == @captures[0].winner
    end

    def captures_count
      @captures.size
    end

    def duration
      @end_time - @start_time
    end
  end
end