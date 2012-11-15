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
    @@REGEX_ASSIST = /L (?'date'.*): "(?'assistant'.*)<\d+><STEAM_\S*><(?'assistant_team'Red|Blue)>" triggered "kill assist" against "(?'target'.*)<\d+><STEAM_\S*><(?'target_team'Red|Blue)>"/
    @@REGEX_CAPTURE = /L (?'date'.*): Team "(?'team'Red|Blue)" triggered "pointcaptured" \(cp "(?'number'\d+)"\) \(cpname "(?'name'.*)"\) \(numcappers/
    @@TEAM_SYMBOL = {'Red' => :red, 'Blue' => :blu}
    @@DATE_FORMAT = '%m/%d/%Y - %T'

    def initialize(verbose=false)
      @match = @curr_round = @curr_cap = nil
      @valid = @match_finished = false
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO if verbose
      @log.level = Logger::WARN unless verbose
      @log.formatter = proc {|severity, datetime, progname, msg| "[#{severity}] #{msg}\n"}
    end

    def parse_file (file, options={})
      return unless File.readable?(file)
      @log.info {"Parsing '#{file}'"}
      File.open(file) {|f| parse_string(f.read, options)}
    end

    def parse_string (string, options={})
      default = {:red => 'Red', :blu => 'Blu', :map => 'N/A'}
      options = default.merge(options)
      @match = Match.new
      @match.red = options[:red]
      @match.blu = options[:blu]
      @match.map = options[:map]
      @log.info {"Map: #{@match.map}, Blu: #{@match.blu}, Red: #{@match.red}"}
      line_number = 0

      string.lines.each do |l|
        line_number += 1
        @log.debug{line_number}
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
        when @@REGEX_ASSIST
          process_assist $1, $2, $3, $4, $5
        end
      end

      @log.info {'Parsing finished.'}
      @log.info {"Score: #{@match.red} #{@match.final_score[:red]}:#{@match.final_score[:blu]} #{@match.blu}"}
      @match
    end

    private
    def parseDate (string)
      DateTime.strptime(string, @@DATE_FORMAT).to_time
    end

    def relative_time (date)
      date - @match.date
    end

    def duration_to_s (duration)
      secs  = duration.to_int
      mins  = secs / 60
      "%02d:%02d" % [mins, secs % 60]
    end

    def process_round_start (date_str)
      date = parseDate(date_str)
      @valid = true
      @match.date = date if @match.rounds.empty?
      @curr_cap = PointCapture.new
      @curr_cap.start_time = relative_time(date)
      @curr_round = Round.new
      @curr_round.start_time = relative_time(date)
      @log.info {"#{duration_to_s (relative_time(date))} - Match start"} if @match.rounds.empty?
      @log.info {"#{duration_to_s (relative_time(date))} - Round start"}
    end

    def process_round_end_win (date_str, team)
      date = parseDate(date_str)
      @valid = false
      @curr_round.winner = @@TEAM_SYMBOL[team]
      @curr_round.end_time = relative_time(date)
      @match.add_round @curr_round
      @log.info {"#{duration_to_s (relative_time(date))} - Round win: #{team}"}
    end

    def process_round_end_stalemate (date_str)
      date = parseDate(date_str)
      @valid = false
      @curr_round.winner = nil
      @ccurr_round.end_time = relative_time(date)
      @match.add_round @curr_round
      @log.info {"#{duration_to_s (relative_time(date))} - Round stalemate"}

    end

    def process_match_end (date_str)
      date = parseDate(date_str)
      @match.end_time = relative_time(date)
      @valid = false
      @match_finished = true
      @log.info {"#{duration_to_s (relative_time(date))} - Game over"}
    end

    def process_capture (date_str, team, cap_number, cap_name)
      date = parseDate(date_str)
      @curr_cap.winner = @@TEAM_SYMBOL[team]
      @curr_cap.number = cap_number
      @curr_cap.name = cap_name
      @curr_cap.end_time = relative_time(date)
      @curr_round.add_capture @curr_cap

      @curr_cap = PointCapture.new
      @curr_cap.start_time = relative_time(date)
      @log.info {"#{duration_to_s (relative_time(date))} - Capture: Team #{team} => #{cap_name}(#{cap_number})"}
    end

    def process_damage (date_str, player, team, value)
      return unless @valid
      date = parseDate(date_str)
      @curr_cap.stats.add_damage @@TEAM_SYMBOL[team], player, value.to_i
      @log.info {"#{duration_to_s (relative_time(date))} - Damage: #{player}[#{team}] (#{value})"}
    end

    def process_heal (date_str, healer, healer_team, target, target_team, value)
      return unless @valid
      date = parseDate(date_str)
      @curr_cap.stats.add_heal @@TEAM_SYMBOL[healer_team], healer, value.to_i
      @curr_cap.stats.add_healed @@TEAM_SYMBOL[target_team], target, value.to_i
      @log.info {"#{duration_to_s (relative_time(date))} - Heal: #{healer}[#{healer_team}] => #{target}[#{target_team}] (#{value})"}
    end

    def process_kill (date_str, killer, killer_team, target, target_team)
      return unless @valid
      date = parseDate(date_str)
      @curr_cap.stats.add_kill @@TEAM_SYMBOL[killer_team], killer
      @curr_cap.stats.add_death @@TEAM_SYMBOL[target_team], target
      @log.info {"#{duration_to_s (relative_time(date))} - Kill: #{killer}[#{killer_team}] => #{target}[#{target_team}]"}
    end

    def process_assist (date_str, assistant, assistant_team, target, target_team)
      return unless @valid
      date = parseDate(date_str)
      @curr_cap.stats.add_assist @@TEAM_SYMBOL[assistant_team], assistant
      @log.info {"#{duration_to_s (relative_time(date))} - Assist: #{assistant}[#{assistant_team}] => #{target}[#{target_team}]"}
    end
  end
end