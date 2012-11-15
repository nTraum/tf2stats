module Tf2Stats
  class Statistics
    attr_reader :kills,:assists, :deaths, :damage, :healed, :heals

    def initialize
      @kills = {:red => Hash.new(0), :blu => Hash.new(0)}
      @assists = {:red => Hash.new(0), :blu => Hash.new(0)}
      @deaths = {:red => Hash.new(0), :blu => Hash.new(0)}
      @damage = {:red => Hash.new(0), :blu => Hash.new(0)}
      @healed = {:red => Hash.new(0), :blu => Hash.new(0)}
      @heals = {:red => Hash.new(0), :blu => Hash.new(0)}
    end

    def add_kill(team, player)
      @kills[team][player] += 1
    end

    def add_assist(team, player)
      @assists[team][player] += 1
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

    def add_sub_stats(sub_stats)
      sub_stats.kills.each_pair do |team, players|
        players.each_pair do |player, value|
          value.times {|_| add_kill(team, player)}
        end
      end
      sub_stats.assists.each_pair do |team, players|
        players.each_pair do |player, value|
          value.times {|_| add_assist(team, player)}
        end
      end
      sub_stats.deaths.each_pair do |team, players|
        players.each_pair do |player, value|
          value.times {|_| add_death(team, player)}
        end
      end
      sub_stats.damage.each_pair do |team, players|
        players.each_pair do |player, value|
          add_damage(team, player, value)
        end
      end
      sub_stats.healed.each_pair do |team, players|
        players.each_pair do |player, value|
          add_healed(team, player, value)
        end
      end
      sub_stats.heals.each_pair do |team, players|
        players.each_pair do |player, value|
          add_heal(team, player, value)
        end
      end
    end
  end
end