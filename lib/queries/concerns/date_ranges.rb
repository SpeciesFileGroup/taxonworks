require 'date'

# For specs see
#   spec/models/collecting_event/dates_spec.rb
#   spec/lib/queries/collecting_event/autocomplete_spec.rb
#
# TODO: isolate code to a gem
module Queries::Concerns::DateRanges
  extend ActiveSupport::Concern

  included do
    # @param [String] search_start_date string in form 'yyyy-mm-dd'
    attr_accessor :start_date

    # @param [String] search_end_date string in form 'yyyy-mm-dd'
    attr_accessor :end_date

    # @param [Boolean] allow_partial partial_overlap_dates
    #   true; found range is only required to start inside supplied range
    #   false; found range must be completely inside supplied range
    attr_accessor :partial_overlap_dates

    attr_reader :start_day, :start_month, :start_year
    attr_reader :end_day, :end_month, :end_year

    def start_date=(value)
      @start_date = value
      @start_year, @start_month, @start_day = start_date.split('-').map(&:to_i)
      @start_date
    end

    def end_date=(value)
      @end_date = value
      @end_year, @end_month, @end_day = end_date.split('-').map(&:to_i)
      @end_date
    end
  end

  def set_dates(params)
    start_date = params[:start_date] unless params[:start_date].blank?
    end_date = params[:end_date] unless params[:end_date].blank?

    @partial_overlap_dates = params[:partial_overlap_dates]
    @partial_overlap_dates = true if @partial_overlap_dates.nil?
  end

  def use_date_range?
    !start_date.blank? && !end_date.blank?
  end

  def start_year_present
    table[:start_date_year].not_eq(nil)
  end

  def equal_start_year
    table[:start_date_year].eq(start_year)
  end

  def equal_start_month
    table[:start_date_month].eq(start_month)
  end

  def equal_or_earlier_start_day
    table[:start_date_day].lteq(start_day)
  end

  def earlier_start_month
    table[:start_date_month].lt(start_month)
  end

  def earlier_start_year
    table[:start_date_year].lt(start_year)
  end

  def equal_end_year
    table[:end_date_year].eq(end_year)
  end

  def equal_end_month
    table[:end_date_month].eq(end_month)
  end

  def equal_or_later_end_day
    table[:end_date_day].gteq(end_day)
  end

  def later_end_month
    table[:end_date_month].gt(end_month)
  end

  def later_end_year
    table[:end_date_year].gt(end_year)
  end

  def end_month_between
    table[:start_date_month].between((1)..(end_month - 1))
  end

  def on_or_before_start_date
    equal_start_year.and(( equal_start_month.and(equal_or_earlier_start_day) ).or(earlier_start_month) )
      .or(earlier_start_year)
  end

  def on_or_after_end_date
    later_end_year.or(
      equal_end_year.and(( equal_end_month.and(equal_or_later_end_day) ).or(later_end_month) )
    )
  end

  def date_range_in_same_year
    # - true == blank later on
    (start_year == end_year) or (end_year - start_year < 2) # test for whole years between date extent
  end

  # part_2e
  def end_year_between
    table[:end_date_year].between((start_year+1)..(end_year-1))
  end

  # part_2s
  def start_year_between
    table[:start_date_year].between((start_year+1)..(end_year-1))
  end

  def equal_or_later_start_day
    table[:start_date_day].gteq(start_day)
  end

  def empty_end_year
    table[:end_date_year].eq(nil)
  end

  def equal_or_earlier_end_day
    table[:end_date_day].lteq(end_day)
  end

  def later_start_month
    table[:start_date_month].between((start_month + 1)..12)
  end

  # Reflects origin variable, rename to clarify
  def part_1s
    equal_start_year.and( later_start_month.or(equal_start_month.and(equal_or_later_start_day)) )
  end

  # Reflects origin variable, rename to clarify
  def part_3s
    table[:start_date_year].eq(end_year)
      .and( table[:start_date_month].lt(end_month).or( table[:start_date_month].eq(end_month).and(table[:start_date_day].lteq(end_day)) ))
  end

  # Reflects origin variable, rename to clarify
  def st_string
    a = nil
    if start_year == end_year
      a = start_year_present.and(part_1s.and(part_3s))
    else
      a = start_year_present.and(part_1s.or(part_3s))
    end

    a = a.or(start_year_between) if !date_range_in_same_year
    a
  end

  # Reflects origin variable, rename to clarify
  def part_1e
    empty_end_year.and(st_string).
      or((equal_end_year.and(end_month_between.or(equal_end_month.and(equal_or_earlier_end_day)))))
  end

  # Reflects origin variable, rename to clarify
  def part_3e
    table[:end_date_year].eq(start_year).and(
      table[:end_date_month].gt(start_month).or(table[:end_date_month].eq(start_month).and(table[:end_date_day].gteq(start_day)))
    )
  end

  # Reflects origin variable, rename to clarify
  def en_string
    q = part_1e

    if start_year == end_year
      q = q.and(part_3e)
    else
      q = q.or(part_3e)
    end

    q = q.or(end_year_between) if !date_range_in_same_year
    q
  end

  # @return [Scope, nil]
  def between_date_range
    return nil unless use_date_range?
    q = st_string

    if partial_overlap_dates
      q = q.or(en_string).or(on_or_before_start_date.and(on_or_after_end_date) )
    else
      q = q.and(en_string)
    end
    q
  end

  # --- Methods below are not part of the between date_range code
  # @return [Date.new, nil]
  def simple_date
    begin
      Date.parse(query_string)
    rescue ArgumentError
      return nil
    end
  end

  def with_start_date
    if d = simple_date
      r = []
      r.push(table[:start_date_day].eq(d.day)) if d.day
      r.push(table[:start_date_month].eq(d.month)) if d.month
      r.push(table[:start_date_year].eq(d.year)) if d.year

      q = r.pop
      r.each do |z|
        q = q.and(z)
      end
      q
    else
      nil
    end
  end

  def with_parsed_date(t = :start)
    if d = simple_date
      r = []
      r.push(table["#{t}_date_day".to_sym].eq(d.day)) if d.day
      r.push(table["#{t}_date_month".to_sym].eq(d.month)) if d.month
      r.push(table["#{t}_date_year".to_sym].eq(d.year)) if d.year

      q = r.pop
      r.each do |z|
        q = q.and(z)
      end
      q
    else
      nil
    end
  end

  def autocomplete_start_date
    if a = with_start_date
      base_query.where(a.to_sql).limit(20)
    else
      nil
    end
  end
  
  def autocomplete_start_or_end_date
    if a = with_parsed_date
      base_query.where(a.or(with_parsed_date(:end)).to_sql).limit(20)
    else
      nil
    end
  end

end
