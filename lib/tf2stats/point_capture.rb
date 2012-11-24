module Tf2Stats
  class PointCapture
    attr_reader :stats, :start_time, :end_time, :winner, :number, :name, :finished

    include Winnable
    include TimeLimited

    def initialize(start_time)
      @start_time = start_time
      @stats = Statistics.new
    end

    def finish(end_time, team, number, name)
      return if @finished
      @finished = true
      @end_time = end_time
      @winner = team
      @number = number
      @name = name
    end
  end
end