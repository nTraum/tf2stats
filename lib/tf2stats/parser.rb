#require './match'
require 'date'
require 'logger'

module Tf2Stats
  class Parser
    @@REGEX_ROUND_START = /L (?'date'.*): World triggered "Round_Start"/
    @@REGEX_ROUND_END_WIN = /L (?'date'.*): World triggered "Round_Win" \(winner "(?'team'Red|Blue)"\)/
    @@REGEX_ROUND_END_STALEMATE = /L (?'date'.*): World triggered "Round_Stalemate"/
    @@REGEX_MATCH_END = /L (?'date'.*): World triggered "Game_Over" reason "/
    @@REGEX_DAMAGE = /L (?'date'.*): "(?'player'.*)<\d+><STEAM_\S*><(?'team'Red|Blue)>" triggered "damage" \(damage "(?'value'\d+)"\)/
    @@REGEX_HEAL = /L (?'date'.*): "(?'healer'.*)<\d+><STEAM_\S*><(?'healer_team'Red|Blue)>" triggered "healed" against "(?'target'.*)<\d+><STEAM_\S*><(?'target_team'Red|Blue)>" \(healing "(?'value'\d+)"\)/
    @@REGEX_KILL = /L (?'date'.*): "(?'killer'.*)<\d+><STEAM_\S*><(?'killer_team'Red|Blue)>" killed "(?'target'.*)<\d+><STEAM_\S*><(?'target_team'Red|Blue)>" with/
    @@REGEX_CAPTURE = /L (?'date'.*): Team "(?'team'Red|Blue)" triggered "pointcaptured" \(cp "(?'number'\d+)"\) \(cpname "(?'name'.*)"\) \(numcappers/
    @@TEAM_SYMBOL = {'Red' => :red, 'Blue' => :blu}
    @@DATE_FORMAT = '%m/%d/%Y - %T'

    def initialize
       @match = @curr_round = @curr_cap = nil
      @valid = @match_finished = false
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO
    end

    def parse_file (file, red='Red', blu='Blu', map=nil)
      return unless File.readable? file

      @log.info "Parsing '#{file}'"
      @log.info "Map: #{map || "none"}, Blu: #{blu}, Red: #{red}"
      @match = Match.new
      @match.red = red
      @match.blu = blu
      line_number = 0

      File.open(file).each do |l|
        line_number += 1
        @log.debug{ line_number }
        break if @match_finished
        case l
        when @@REGEX_ROUND_START
          process_round_start $1
        when @@REGEX_ROUND_END_WIN
          process_round_end_win $1, $2
        when @@REGEX_ROUND_END_STALEMATE
          process_round_end_stalemate $1
        when @@REGEX_MATCH_END
          process_match_end $1
        when @@REGEX_CAPTURE
          process_capture $1, $2, $3, $4
        when @@REGEX_DAMAGE
          process_damage $1, $2, $3, $4
        when @@REGEX_HEAL
          process_heal $1, $2, $3, $4, $5, $6
        when @@REGEX_KILL
          process_kill $1, $2, $3, $4, $5
        end
      end

      @log.info 'Parsing finished.'
      @log.info "Score: #{@match.red} #{@match.final_score[:red]}:#{@match.final_score[:blu]} #{@match.blu}"
      @match
    end

    private
    def parseDate (string)
      DateTime.strptime(string, @@DATE_FORMAT).to_time
    end

    def process_round_start (date_str)
      @valid = true
      date = parseDate(date_str)
      @match.date = date if @match.rounds.empty?
      @log.info "Match start" if @match.rounds.empty?
      @log.info "Round start"
      @curr_cap = PointCapture.new
      @curr_cap.start_time = date - @match.date
      @curr_round = Round.new
      @curr_round.start_time = date - @match.date
    end

    def process_round_end_win (date_str, team)
      @log.info "Round win: #{team}"
      @valid = false
      @curr_round.winner = @@TEAM_SYMBOL[team]
      @match.add_round @curr_round
    end

    def process_round_end_stalemate (date_str)
      @log.info "Round stalemate"
      @valid = false
      @curr_round.winner = nil
      @match.add_round @curr_round
    end

    def process_match_end (date_str)
      @log.info "Game over"
      @valid = false
      @match_finished = true
    end

    def process_capture (date_str, team, cap_number, cap_name)
      @log.info "Capture: Team #{team} => #{cap_name}(#{cap_number})"
      date = parseDate(date_str)
      @curr_cap.winner = @@TEAM_SYMBOL[team]
      @curr_cap.number = cap_number
      @curr_cap.name = cap_name
      @curr_cap.duration = date - @curr_cap.start_time
      @curr_round.add_capture @curr_cap

      @curr_cap = PointCapture.new
      @curr_cap.start_time = date - @match.date
    end

    def process_damage (date_str, player, team, value)
      return unless @valid
      @log.info "Damage: #{player}[#{team}] (#{value})"
      @curr_cap.add_damage @@TEAM_SYMBOL[team], player, value.to_i
    end

    def process_heal (date_str, healer, healer_team, target, target_team, value)
      return unless @valid
      @log.info "Heal: #{healer}[#{healer_team}] => #{target}[#{target_team}] (#{value})"
      @curr_cap.add_heal @@TEAM_SYMBOL[healer_team], healer, value.to_i
      @curr_cap.add_healed @@TEAM_SYMBOL[target_team], target, value.to_i
    end

    def process_kill (date_str, killer, killer_team, target, target_team)
      return unless @valid
      @log.info "Kill: #{killer}[#{killer_team}] => #{target}[#{target_team}]"
      @curr_cap.add_kill @@TEAM_SYMBOL[killer_team], killer
      @curr_cap.add_death @@TEAM_SYMBOL[target_team], target
    end
  end
end