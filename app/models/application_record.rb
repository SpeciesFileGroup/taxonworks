class ApplicationRecord < ActiveRecord::Base
  # Required here due to the eager load before config/routes.rb
  include NilifyBlanks

  # Prettify SQL in console
  # !! Do not use, it will break queries since we use .to_sql in constructing
  # queries and prettify currently does things like turning `)::float` into
  # `) : : float`.
  # Use .pp_sql in place of .to_sql where you want prettified output.
  #include PpSql::ToSqlBeautify if defined?(Rails::Console)

  self.abstract_class = true

  # Will run block on transaction, repeating 3 times if failed due to ActiveRecord:DeadLock exception.
  def self.transaction_with_retry(&block)
    retry_count = 0
    begin
      transaction &block
    rescue ActiveRecord::Deadlocked
      raise if retry_count > 3
      # Exponential backoff with proportional random wait time.
      sleep 2**(retry_count)*(1+rand)

      retry_count += 1
      retry
    end
  end

end
