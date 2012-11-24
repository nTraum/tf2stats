module Tf2Stats

  class Match
    attr_reader :rounds, :scores, :stats, :chat, :end_time, :finished
    attr_accessor :date, :red, :blu, :map

    include Winnable
    include TimeLimited

    def initialize
      @finished = false
      @stats = Statistics.new
      @rounds = []
      @chat = []
      @scores = [{:red => 0, :blu => 0}]
    end

    def start_time
      return 0
    end

    def add_chat_message chat_message
      @chat << chat_message
    end

    def add_round round
      @stats.add_sub_stats round.stats
      @rounds << round
      add_score round.winner
    end

    def score
      @scores.last
    end

    def winner
      return :blu if score[:red] < score[:red]
      return :red if score[:red] > score[:blu]
    end

    def finish(end_time)
      return if @finished
      @finished = true
      @end_time = end_time
    end

    private
    def add_score team
      @scores << @scores.last.clone
      @scores.last[team] += 1 if team
    end
  end
end