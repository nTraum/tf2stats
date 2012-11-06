# require './point_capture'

module Tf2Stats
  class Round
    attr_reader :captures, :duration
    attr_accessor :start_time, :winner

    def initialize
      @duration = 0
      @captures = []
    end

    def add_capture point_capture
      @captures << point_capture
      @duration += point_capture.duration
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
  end
end