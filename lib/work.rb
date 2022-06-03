# A module to (roughly) estimate productivity.  Uses the 'updated_at' timestamp as a proxy.
module Work

  BATCH_COUNT_CUTOFF = 500.0
  BATCH_EFFICIENCY_CUTOFF = 20.0

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
          current_session[:efficiency] = (current_session[:count].to_f / ((current_session[:end] - current_session[:start]) / 60.0)).round(3)
        end

        # TODO: add efficiency comparison here
        current_session[:batch] = true if (current_session[:count] > BATCH_COUNT_CUTOFF) &&  (current_session[:efficiency] > BATCH_EFFICIENCY_CUTOFF )

        sessions.push current_session
        current_session = new_session(current_time)

        # session continues
      else
        current_session[:count] += 1
      end
      last_time = current_time
    end

    current_session[:end] = last_time
    if current_session[:count] == 1
      current_session[:efficiency] = 0.0
    else
      current_session[:efficiency] = (current_session[:count].to_f / ((current_session[:end] - current_session[:start]) / 60.0)).round(3)
    end
    current_session[:batch] = true if (current_session[:count] > BATCH_COUNT_CUTOFF) &&  (current_session[:efficiency] > BATCH_EFFICIENCY_CUTOFF )
    sessions.push current_session

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

  # @return [Integer, nil]
  #   in seconds
  def self.total_time(sessions, include_batch = false)
    return 0 if sessions.nil?
    t = 0
    sessions.each do |s|
      next if !include_batch && s[:batch]
      t += s[:end] - s[:start]
    end
    t
  end

  def self.total_time_in_hours(sessions, include_batch = false)
    ( total_time(sessions, include_batch) / 3600.0).round(2)
  end

  def self.total_batch_sessions(sessions)
    return 0 if sessions.nil?
    i = 0
    sessions.each do |s|
      next if !s[:batch]
      i += 1 if s[:count]
    end
    i
  end

  def self.sum_count_without_batch_sessions(sessions)
    return 0 if sessions.nil?
    i = 0
    sessions.each do |s|
      next if s[:batch]
      i += s[:count]
    end
    i
  end

  def self.sum_count(sessions, include_batch = false)
    return 0 if sessions.nil?
    i = 0
    sessions.each do |s|
      next if !include_batch && s[:batch]
      i += s[:count]
    end
    i
  end

  def self.average_records_per_minute(sessions, include_batch = false)
    return 0 if sessions.nil?
    i = 0
    t = 0
    sessions.each do |s|
      next if !include_batch && s[:batch]
      i += s[:count]
      t += s[:end] - s[:start]
    end
    (i.to_f / (t / 60)).round(3)
  end

  def self.average_minutes_per_record(sessions, include_batch = false)
    (1.00 / average_records_per_minute(sessions, include_batch)).round(3)
  end


end
