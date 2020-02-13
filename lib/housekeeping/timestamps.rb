# Concern that provides timestamp related methods for housekeeping.
#
#  !! https://github.com/ankane/groupdate is now included in TW, and includes many grouping scopes!
#
module Housekeeping::Timestamps
  extend ActiveSupport::Concern

  included do
    # related_class = self.name
    # related_table_name = self.table_name

    # TODO: Coerce to DateTime in a cheaper way when date param already is either Date, Time or DateTime rather than String.
    scope :created_before_date, ->(date) { where(self.arel_table[:created_at].lt DateTime.parse(date.to_s)) }
    scope :created_in_date_range, ->(start, c_end) {
      where(created_at: DateTime.parse(start.to_s)..DateTime.parse(c_end.to_s))
    }
    scope :updated_in_date_range, ->(start, u_end) {
      where(updated_at: DateTime.parse(start.to_s)..DateTime.parse(u_end.to_s))
    }

    scope :recently_created, -> (range = 1.weeks.ago..Time.now) { where(created_at: range) }
    scope :recently_updated, -> (range = 1.weeks.ago..Time.now) { where(updated_at: range) }

  end

  module ClassMethods
    # @return [Scope]
    def first_created
      all.order(created_at: :asc).first
    end

    # @return [Scope]
    def last_created
      all.order(created_at: :desc).first
    end

    # @return [Scope]
    def first_updated
      all.order(updated_at: :asc).first
    end

    # @return [Scope]
    def last_updated
      all.order(updated_at: :desc).first
    end

    # @return [Scope]
    def created_this_week
      where(created_at: 1.weeks.ago..Time.now)
    end

    # @return [Scope]
    def updated_this_week
      where(updated_at: 1.weeks.ago..Time.now)
    end

    # @return [Scope]
    def created_today
      where(created_at: 1.day.ago..Time.now)
    end

    # @return [Scope]
    def updated_today
      where(updated_at: 1.day.ago..Time.now)
    end

    #  Otu.created_in_last(2.weeks)
    # @return [Scope]
    def created_in_last(time)
      where(created_at: time.ago..Time.now)
    end

    #  Otu.created_in_last(1.month)
    # @return [Scope]
    def updated_in_last(time)
      where(updated_at: time.ago..Time.now)
    end

    # @return [Scope]
    def created_last(number = 10)
      limit(number).order(created_at: :DESC)
    end

    # @return [Scope]
    def updated_last(number = 10)
      limit(number).order(updated_at: :DESC)
    end

  end

  # @return [Array]
  def data_breakdown_for_chartkick_recent
    Rails.application.eager_load!
    data = []
    has_many_relationships.each do |name|

      today      = self.send(name).created_today.count # in_project(self).count
      this_week  = self.send(name).created_this_week.count # in_project(self).count
      this_month = self.send(name).created_in_last(4.weeks).count # in_project(self).count

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

