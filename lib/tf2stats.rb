%w(version winnable time_limitable point_capture round match parser statistics chat_message).each do |e|
  require "tf2stats/#{e}"
end