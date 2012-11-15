%w(version point_capture round match parser statistics).each do |e|
  require "tf2stats/#{e}"
end