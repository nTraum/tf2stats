module Tf2Stats


  # Represents a message written in chat
  #
  #
  #@!attribute [r] time
  #   @return [Float] timestamp of the message in seconds, relative to match begin
  #@!attribute [r] player
  #   @return [String] nickname of the player who sent the message
  #@!attribute [r] message
  #   @return [Float] content of the message
  #@!attribute [r] team
  #   @return [Symbol] team of the player, either :red or :blu
  #
  class ChatMessage
    attr_reader :time, :player, :message, :team

    def initialize(time, team, player, message, teamchat = false)
      @time = time
      @team = team
      @player = player
      @message = message
      @teamchat = teamchat
    end

    # indicates if the message was sent to the team
    # @return [Boolean] true if the message was sent to the player's team only
    def teamchat?
      return @teamchat
    end
  end
end