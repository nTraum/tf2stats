module Tf2Stats
  class PointCapture
    attr_reader :kills, :deaths, :damage, :healed, :heals
    attr_accessor :start_time, :end_time, :winner, :number, :name

    def initialize
      @kills = {:red => Hash.new(0), :blu => Hash.new(0)}
      @deaths = {:red => Hash.new(0), :blu => Hash.new(0)}
      @damage = {:red => Hash.new(0), :blu => Hash.new(0)}
      @healed = {:red => Hash.new(0), :blu => Hash.new(0)}
      @heals = {:red => Hash.new(0), :blu => Hash.new(0)}
    end

    def add_kill(team, player)
      @kills[team][player] += 1
    end

    def add_death(team, player)
      @deaths[team][player] += 1
    end

    def add_damage(team, player, value)
      @damage[team][player] += value
    end

    def add_healed(team, player, value)
      @healed[team][player] += value
    end

    def add_heal(team, player, value)
      @heals[team][player] += value
    end

    def duration
      @end_time - @start_time
    end
  end
end