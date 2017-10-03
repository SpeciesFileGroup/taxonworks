# Concern that provides timestamp related methods for housekeeping.
#
#  !! https://github.com/ankane/groupdate is now included in TW, and includes many grouping scopes!
#
module Housekeeping::Timestamps
  extend ActiveSupport::Concern

  included do
    # related_class = self.name
    # related_table_name = self.table_name

    scope :created_before_date, -> (date) { where('created_at < ?', "#{date}") }
    scope :created_in_date_range, ->(start, stop) { where('created_at >= ? and created_at <= ?', start, stop) }
    scope :updated_in_date_range, ->(start, stop) { where('updated_at >= ? and updated_at <= ?', start, stop) }
  end

  module ClassMethods
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
      where(created_at: time.ago..Time.now)
    end

    #  Otu.created_in_last(1.month)
    def updated_in_last(time)
      where(updated_at: time.ago..Time.now)
    end

    def created_last(number = 10)
      limit(number).order(created_at: :DESC)
    end

    def updated_last(number = 10)
      limit(number).order(updated_at: :DESC)
    end

  end

  def data_breakdown_for_chartkick_recent
    Rails.application.eager_load!
    data = []
    has_many_relationships.each do |name|

      today      = self.send(name).created_today.count # in_project(self).count
      this_week  = self.send(name).created_this_week.count # in_project(self).count
      this_month =self.send(name).created_in_last(4.weeks).count # in_project(self).count

      if this_month > 0
        data.push({
                    name: name.to_s.humanize,
                    data: {
                      'this week'  => this_week,
                      today:       today,
                      'this month' => this_month
                    }
                  })
      end
    end
    data
  end

end

