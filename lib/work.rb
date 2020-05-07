# A module to (roughly) estimate productivity.  Uses the 'updated_at' timestamp as a proxy.
module Work

  # @return [Array]
  # @param records [An ActiveRecord scope]
  #  A session is a contiguous period of time in which the gap between
  #  updated records is no longer than 60 minutes
  def self.sessions(records)
    return [] if records.none?

    r = records.to_a

    a = r.shift
    last_time = a.updated_at

    sessions = [ ]
    current_session = new_session(last_time)

    while r.count != 0 
      a = r.shift

      current_time = a.updated_at

      # more than one hour between subsequent specimens
      # sessions ends
      if current_time - last_time > 3600.0

        current_session[:end] = last_time

        if current_session[:count] == 1
          current_session[:efficiency] = 0.0 
        else
          current_session[:efficiency] = current_session[:count].to_f / ((current_session[:end] - current_session[:start]) / 60.0)
        end

        sessions.push current_session
        current_session = new_session(current_time)

        # session continues
      else
        current_session[:count] += 1 
      end
      last_time = current_time
    end

    sessions
  end

  # @return [Hash]
  def self.new_session(current_time)
    return {
      start: current_time, # Time of session start
      end: nil,            # Time of session end
      count: 1,            # Number of records updated
      efficiency: nil      # Records updated per minute
    }
  end

  # @return [Integer, nil]
  #   in seconds
  def self.total_time(sessions)
    return 0 if sessions.nil?
    t = 0
    sessions.each do |s|
      t += s[:end] - s[:start]
    end
    t 
  end
end
