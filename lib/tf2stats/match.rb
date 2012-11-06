#require './round'

module Tf2Stats
  class Match
    attr_reader :rounds, :duration, :scores
    attr_accessor :date, :red, :blu, :map

    def initialize 
      @duration = 0
      @rounds = []
      @scores = [{:red => 0, :blu => 0}]
    end

    def add_round round
      @rounds << round
      @duration += round.duration
      add_score round.winner
    end

    def rounds_count
      @rounds.size
    end

    def final_score
      @scores.last
    end

    def winner
      :red if won_red?
      :blu if won_blu?
    end

    def won_blu?
      @scores.last[:red] < @scores.last[:blu]
    end

    def won_red?
      @scores.last[:red] > @scores.last[:blu]
    end

    def stalemate?
      @scores.last[:red] == @scores.last[:blu]
    end

    private
    def add_score team
      @scores << @scores.last.clone
      @scores.last[team] += 1 if team
    end
  end
end