module Tf2Stats
  class Match
    attr_reader :rounds, :scores, :stats
    attr_accessor :date, :red, :blu, :map, :end_time

    def initialize
      @stats = Statistics.new
      @rounds = []
      @scores = [{:red => 0, :blu => 0}]
    end

    def start_time
      return 0
    end

    def duration
      @end_time
    end

    def add_round round
      @stats.add_sub_stats round.stats
      @rounds << round
      add_score round.winner
    end

    def rounds_count
      @rounds.size
    end

    def final_score
      @scores.last
    end

    def winner
      return :blu if won_blu?
      return :red if won_red?
    end

    def won_blu?
      @scores.last[:red] < @scores.last[:blu]
    end

    def won_red?
      @scores.last[:red] > @scores.last[:blu]
    end

    def stalemate?
      won_blu? == false && won_red? == false
    end

    private
    def add_score team
      @scores << @scores.last.clone
      @scores.last[team] += 1 if team
    end
  end
end