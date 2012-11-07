# require './point_capture'

module Tf2Stats
  class Round
    attr_reader :captures, :duration, :kills, :deaths, :damage, :healed, :heals
    attr_accessor :start_time, :end_time, :winner

    def initialize
      @kills = {:red => Hash.new(0), :blu => Hash.new(0)}
      @deaths = {:red => Hash.new(0), :blu => Hash.new(0)}
      @damage = {:red => Hash.new(0), :blu => Hash.new(0)}
      @healed = {:red => Hash.new(0), :blu => Hash.new(0)}
      @heals = {:red => Hash.new(0), :blu => Hash.new(0)}
      @duration = 0
      @captures = []
    end

    def add_capture point_capture
      cumulate_stats point_capture
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

    private

    def cumulate_stats point_capture
      point_capture.kills.each_pair do |team, players|
        players.each_pair do |player, value|
          @kills[team][player] += value
        end
      end
      point_capture.deaths.each_pair do |team, players|
        players.each_pair do |player, value|
          @deaths[team][player] += value
        end
      end
      point_capture.damage.each_pair do |team, players|
        players.each_pair do |player, value|
          @damage[team][player] += value
        end
      end
      point_capture.healed.each_pair do |team, players|
        players.each_pair do |player, value|
          @healed[team][player] += value
        end
      end
      point_capture.heals.each_pair do |team, players|
        players.each_pair do |player, value|
          @heals[team][player] += value
        end
      end
    end
  end
end