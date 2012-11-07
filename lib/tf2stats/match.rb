module Tf2Stats
  class Match
    attr_reader :rounds, :scores, :kills, :deaths, :damage, :healed, :heals
    attr_accessor :date, :red, :blu, :map, :end_time

    def initialize
      @kills = {:red => Hash.new(0), :blu => Hash.new(0)}
      @deaths = {:red => Hash.new(0), :blu => Hash.new(0)}
      @damage = {:red => Hash.new(0), :blu => Hash.new(0)}
      @healed = {:red => Hash.new(0), :blu => Hash.new(0)}
      @heals = {:red => Hash.new(0), :blu => Hash.new(0)}
      @rounds = []
      @scores = [{:red => 0, :blu => 0}]
    end

    def duration
      @end_time
    end

    def add_round round
      @rounds << round
      add_score round.winner
      cumulate_stats round
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
      @scores.last[:red] == @scores.last[:blu]
    end

    private
    def add_score team
      @scores << @scores.last.clone
      @scores.last[team] += 1 if team
    end

    def cumulate_stats (round)
      round.kills.each_pair do |team, players|
        players.each_pair do |player, value|
          @kills[team][player] += value
        end
      end
      round.deaths.each_pair do |team, players|
        players.each_pair do |player, value|
          @deaths[team][player] += value
        end
      end
      round.damage.each_pair do |team, players|
        players.each_pair do |player, value|
          @damage[team][player] += value
        end
      end
      round.healed.each_pair do |team, players|
        players.each_pair do |player, value|
          @healed[team][player] += value
        end
      end
      round.heals.each_pair do |team, players|
        players.each_pair do |player, value|
          @heals[team][player] += value
        end
      end
    end
  end
end