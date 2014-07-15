# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::Timestamps
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    # Scopes
    def created_this_week
      where(created_at: 1.weeks.ago..Time.now) 
    end

    def updated_this_week
      where(updated_at: 1.weeks.ago..Time.now) 
    end

    def created_today
      where(created_at: 1.day.ago..Time.now)
    end

    def updated_today
      where(updated_at: 1.day.ago..Time.now)
    end

    #  Otu.created_in_last(2.weeks)
    def created_in_last(time)
      where(created_at: time..Time.now  )
    end 

    def updated_in_last(time)
      where(updated_at: time..Time.now)
    end
  end

end

