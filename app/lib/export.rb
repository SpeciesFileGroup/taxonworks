
module ::Export

  def self.get_connection
    ActiveRecord::Base.connection.raw_connection
  end

end
