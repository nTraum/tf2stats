# require './point_capture'

module Tf2Stats
  class Round
    attr_reader :captures, :duration
    attr_accessor :start_time, :end_time, :winner

    def initialize
      @duration = 0
      @captures = []
    end

    def add_capture point_capture
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

    def captures_count
      @captures.size
    end

    def duration
      @end_time - @start_time
    end
  end
end