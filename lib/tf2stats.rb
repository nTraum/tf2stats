%w(version point_capture round match parser).each do |e|
  require "tf2stats/#{e}"
end