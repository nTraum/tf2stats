module Tf2Stats
  class PointCapture
    attr_reader :stats
    attr_accessor :start_time, :end_time, :winner, :number, :name

    include Winnable

    def initialize
      @stats = Statistics.new
    end

    def duration
      end_time - start_time
    end
  end
end