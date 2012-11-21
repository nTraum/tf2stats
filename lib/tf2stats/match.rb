module Tf2Stats

  class Match
    attr_reader :rounds, :scores, :stats, :chat, :end_time
    attr_accessor :date, :red, :blu, :map

    include Winnable
    include TimeLimitable

    def initialize
      @end_time = 0
      @stats = Statistics.new
      @rounds = []
      @chat = []
      @scores = [{:red => 0, :blu => 0}]
    end

    # start time of the match
    # @return [Fixnum] is always 0
    def start_time
      return 0
    end

    # adds a new chat message to the chat
    # @param  chat_message [ChatMessage] the specified ChatMessage
    def add_chat_message chat_message
      @chat << chat_message
    end

    # adds a new round to the match
    # @param  round [Round] the specified round
    def add_round round
      @stats.add_sub_stats round.stats
      @rounds << round
      add_score round.winner
    end

    # final score at match end
    # @return [Hash] scores of both teams as a hash
    # @example
    #     {:red => 2, :blu => 7}
    def score
      @scores.last
    end

    # winner of the match
    # @return [Symbol, nil] winner of the match, either nil, :blu or :red
    def winner
      return :blu if score[:red] < score[:red]
      return :red if score[:red] > score[:blu]
    end

    def is_finished(end_time)
      @end_time = end_time
    end

    private
    def add_score team
      @scores << @scores.last.clone
      @scores.last[team] += 1 if team
    end
  end
end