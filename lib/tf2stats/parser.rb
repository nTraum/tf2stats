require 'date'
require 'logger'

module Tf2Stats

  class Parser
    REGEX_DATE = 'L (?\'date\'.*):'
    REGEX_PLAYER = '"(?\'player_nick\'.+)<(?\'player_uid\'\d+)><(?\'player_steamid\'STEAM_\S+)><(?\'player_team\'Red|Blue)>"'
    REGEX_TARGET = '"(?\'target_nick\'.+)<(?\'target_uid\'\d+)><(?\'target_steamid\'STEAM_\S+)><(?\'target_team\'Red|Blue)>"'
    REGEX_MESSAGE = '"(?\'message\'.*)"'
    REGEX_ROUND_START = /#{REGEX_DATE} World triggered "Round_Start"/
    REGEX_ROUND_END_WIN = /#{REGEX_DATE} World triggered "Round_Win" \(winner "(?'team'Red|Blue)"\)/
    REGEX_ROUND_END_STALEMATE = /#{REGEX_DATE} World triggered "Round_Stalemate"/
    REGEX_MATCH_END = /#{REGEX_DATE} World triggered "Game_Over" reason "/
    REGEX_DAMAGE = /#{REGEX_DATE} #{REGEX_PLAYER} triggered "damage" \(damage "(?'value'\d+)"\)/
    REGEX_HEAL = /#{REGEX_DATE} #{REGEX_PLAYER} triggered "healed" against #{REGEX_TARGET} \(healing "(?'value'\d+)"\)/
    REGEX_KILL = /#{REGEX_DATE} #{REGEX_PLAYER} killed #{REGEX_TARGET} with/
    REGEX_ASSIST = /#{REGEX_DATE} #{REGEX_PLAYER} triggered "kill assist" against #{REGEX_TARGET}/
    REGEX_CAPTURE = /#{REGEX_DATE} Team "(?'team'Red|Blue)" triggered "pointcaptured" \(cp "(?'cp_number'\d+)"\) \(cpname "(?'cp_name'.*)"\) \(numcappers/
    REGEX_CHAT_SAY = /#{REGEX_DATE} #{REGEX_PLAYER} say #{REGEX_MESSAGE}/
    REGEX_CHAT_TEAM_SAY = /#{REGEX_DATE} #{REGEX_PLAYER} say_team #{REGEX_MESSAGE}/
    DATE_FORMAT = '%m/%d/%Y - %T'
    private_constant :REGEX_PLAYER, :REGEX_TARGET, :REGEX_ROUND_START, :REGEX_ROUND_END_WIN, :REGEX_ROUND_END_STALEMATE, :REGEX_MATCH_END, :REGEX_DAMAGE, :REGEX_HEAL, :REGEX_KILL, :REGEX_ASSIST, :REGEX_CAPTURE, :REGEX_CHAT_SAY, :REGEX_CHAT_TEAM_SAY, :DATE_FORMAT

    @@TEAM_SYMBOL = {'Red' => :red, 'Blue' => :blu}

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
      File.open(file) {|f| parse_string(f.read.force_encoding('UTF-8').encode('UTF-16LE', :invalid => :replace, :replace => '').encode('UTF-8'), options)}
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

        if res = l.match(REGEX_ROUND_START)
          process_round_start res[:date]
        elsif res = l.match(REGEX_ROUND_END_WIN)
          process_round_end_win res[:date], res[:team]
        elsif res = l.match(REGEX_ROUND_END_STALEMATE)
          process_round_end_stalemate res[:date]
        elsif res = l.match(REGEX_MATCH_END)
          process_match_end res[:date]
        elsif res = l.match(REGEX_CAPTURE)
          process_capture res[:date], res[:team], res[:cp_number], res[:cp_name]
        elsif res = l.match(REGEX_DAMAGE)
          process_damage res[:date], res[:player_steamid], res[:player_team], res[:value]
        elsif res = l.match(REGEX_HEAL)
          process_heal res[:date], res[:player_steamid], res[:player_team], res[:target_steamid], res[:target_team], res[:value]
        elsif res = l.match(REGEX_KILL)
          process_kill res[:date], res[:player_steamid], res[:player_team], res[:target_steamid], res[:target_team]
        elsif res = l.match(REGEX_ASSIST)
          process_assist res[:date], res[:player_steamid], res[:player_team], res[:target_steamid], res[:target_team]
        elsif res = l.match(REGEX_CHAT_SAY)
          process_say res[:date], res[:player_steamid], res[:player_team], res[:message]
        elsif res = l.match(REGEX_CHAT_TEAM_SAY)
          process_team_say res[:date], res[:player_steamid], res[:player_team], res[:message]
        end
      end

      @log.info {'Parsing finished.'}
      @log.info {"Score: #{@match.red} #{@match.final_score[:red]}:#{@match.final_score[:blu]} #{@match.blu}"}
      @match
    end

    private
    def parseDate (string)
      DateTime.strptime(string, DATE_FORMAT).to_time
    end

    def relative_time (date)
      (date - @match.date).to_i
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
      @curr_cap = PointCapture.new(relative_time(date))
      @curr_round = Round.new(relative_time(date))
      @log.info {"#{duration_to_s (relative_time(date))} - Match start"} if @match.rounds.empty?
      @log.info {"#{duration_to_s (relative_time(date))} - Round start"}
    end

    def process_round_end_win (date_str, team)
      date = parseDate(date_str)
      @valid = false
      @curr_round.finish(relative_time(date), @@TEAM_SYMBOL[team])
      @match.add_round @curr_round
      @log.info {"#{duration_to_s (relative_time(date))} - Round win: #{team}"}
    end

    def process_round_end_stalemate (date_str)
      date = parseDate(date_str)
      @valid = false
      @curr_round.finish(relative_time(date), nil)
      @match.add_round @curr_round
      @log.info {"#{duration_to_s (relative_time(date))} - Round stalemate"}

    end

    def process_match_end (date_str)
      date = parseDate(date_str)
      @match.finish(relative_time(date))
      @valid = false
      @match_finished = true
      @log.info {"#{duration_to_s (relative_time(date))} - Game over"}
    end

    def process_capture (date_str, team, cap_number, cap_name)
      date = parseDate(date_str)
      @curr_cap.is_capped(relative_time(date), @@TEAM_SYMBOL[team], cap_number, cap_name)
      @curr_round.add_capture @curr_cap

      @curr_cap = PointCapture.new(relative_time(date))
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

    def process_say(date_str, player, team, message)
      return unless @valid
      date = parseDate(date_str)
      @match.add_chat_message ChatMessage.new(relative_time(date), @@TEAM_SYMBOL[team], player, message, false)
      @log.info {"#{duration_to_s (relative_time(date))} - Say: #{player}[#{team}] => '#{message}'"}
    end

    def process_team_say(date_str, player, team, message)
      return unless @valid
      date = parseDate(date_str)
      @match.add_chat_message ChatMessage.new(relative_time(date), @@TEAM_SYMBOL[team], player, message, true)
      @log.info {"#{duration_to_s (relative_time(date))} - Say Team: #{player}[#{team}] => '#{message}'"}
    end
  end
end
