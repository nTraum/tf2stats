module Tf2Stats
  class ChatMessage
    attr_reader :time, :player, :message, :team

    def initialize(time, team, player, message, teamchat = false)
      @time = time
      @team = team
      @player = player
      @message = message
      @teamchat = teamchat
    end

    def teamchat?
      return @teamchat
    end
  end
end