module Tf2Stats
  module TimeLimited
    def duration
      return if end_time.nil? or start_time.nil?
      end_time - start_time
    end
  end
end