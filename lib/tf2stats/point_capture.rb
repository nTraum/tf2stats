module Tf2Stats
  class PointCapture
    attr_reader :stats, :start_time, :end_time, :winner, :number, :name

    include Winnable
    include TimeLimitable

    def initialize(start_time)
      @start_time = start_time
      @stats = Statistics.new
    end

    def is_capped(end_time, team, number, name)
      @end_time = end_time
      @winner = team
      @number = number
      @name = name
    end
  end
end