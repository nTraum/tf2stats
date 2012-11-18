module Tf2Stats

  class Match
    attr_reader :rounds, :scores, :stats, :chat
    attr_accessor :date, :red, :blu, :map, :end_time

    def initialize
      @stats = Statistics.new
      @rounds = []
      @chat = []
      @scores = [{:red => 0, :blu => 0}]
    end


    # start time of the match
    # @return [Float] is always 0
    def start_time
      return 0
    end


    # adds a new chat message to the chat
    # @param  chat_message [ChatMessage] the specified ChatMessage
    def add_chat_message chat_message
      @chat << chat_message
    end


    # duration if the actual match in seconds
    # @return [Float] duration of the whole match, in seconds
    def duration
      @end_time
    end


    # adds a new round to the match
    # @param  round [Round] the specified round
    def add_round round
      @stats.add_sub_stats round.stats
      @rounds << round
      add_score round.winner
    end

    # number of rounds that has been played
    # @return [Fixnum] number of rounds of this match
    def rounds_count
      @rounds.size
    end

    # final score at match end
    # @return [Hash] scores of both teams as a hash
    # @example
    #     {:red => 2, :blu => 7}
    def final_score
      @scores.last
    end

    # winner of the match
    # @return [Symbol, nil] winner of the match, either nil, :blu or :red
    def winner
      return :blu if won_blu?
      return :red if won_red?
    end

    # determines if team BLU won the match
    # @return [Boolean] true if team BLU won
    def won_blu?
      @scores.last[:red] < @scores.last[:blu]
    end

    # determines if team RED won the match
    # @return [Boolean] true if team RED won
    def won_red?
      @scores.last[:red] > @scores.last[:blu]
    end

    # determines if this match ended in a tie
    # @return [Boolean] true if none of both teams won
    def stalemate?
      won_blu? == false && won_red? == false
    end

    private
    def add_score team
      @scores << @scores.last.clone
      @scores.last[team] += 1 if team
    end
  end
end