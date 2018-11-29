
module Queries::Concerns::DateRanges
  extend ActiveSupport::Concern

  included do

    # &start_date_day=
    # &end_date_day=
    # &start_date_month=
    # &end_date_month=
    # &start_date_year=
    # &end_date_year=
    # &st_datepicker=
    # &verbatim_locality_text=
    # &any_label_text=
    # &identifier_text= 

    attr_accessor :start_date
    attr_accessor :end_date

    # Boolean [True, False]
    attr_accessor :partial_overlap_dates

    attr_accessor :start_day, :start_month, :start_year
    attr_accessor :end_day, :end_month, :end_year

  end

  def set_dates(params)
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @partial_overlap_dates = params[:partial_overlap_dates]
    @partial_overlap_dates = true if @partial_overlap_dates.nil?

    @start_year, @start_month, @start_day = start_date.split('/').map(&:to_i) if @start_date.present?
    @end_year, @end_month, @end_day = end_date.split('/').map(&:to_i) if @end_date.present?
  end

  def start_year_required
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

  # sp1 (OK!?)
  def on_or_before_start_date
    (
      equal_start_year.and( 
                           (equal_start_month.and(equal_or_earlier_start_day)).or(earlier_start_month))
    ).or(earlier_start_year)
  end

  # sp2 (OK!?)
  def on_or_after_end_date
    equal_end_year.and(( equal_end_month.and(equal_or_later_end_day) ).or(later_end_month))
      .or(later_end_year)
  end

  # OK
  def date_range_in_same_year # - true == blank
    (start_year == end_year) or (end_year - start_year < 2) # test for whole years between date exten
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

  # OK!
  def part_1s #  start_date_to_end_start_year
    equal_start_year.and((table[:start_date_month].between((start_month + 1)..12).or(equal_start_month.and(equal_or_later_start_day))))
  end

  # OK!?
  def part_3s # begining_of_end_year_to_end_date
    table[:start_date_year].eq(end_year)
      .and( table[:start_date_month].lt(end_month).or( table[:start_date_month].eq(end_month).and(table[:start_date_day].lteq(end_day)) )
          )
  end

  # OK!
  def st_string
    a = nil 

    # Unify with year stuff below?! 
    if start_year == end_year # select_1_3
      a = start_year_required.and(part_1s.and(part_3s))
    else
      a = start_year_required.and(part_1s.or(part_3s))
    end

    # date_range_in_same_year
    a = a.or(start_year_between) if !date_range_in_same_year
    a
  end 

  def empty_end_year
    table[:end_date_year].eq(nil)
  end

  def equal_or_earlier_end_day
    table[:end_date_day].lteq(end_day)
  end

  def part_1e
    empty_end_year.and(st_string).
      or((equal_end_year.and(end_month_between.or(equal_end_month.and(equal_or_earlier_end_day)))))
  end 

  def part_3e
    table[:end_date_year].eq(start_year).and(
      table[:end_date_month].gt(start_month).or(table[:end_date_month].eq(start_month).and(table[:end_date_day].gteq(start_day)))
    )
  end

  # == en_string
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

  def between_date_range # special_part

    q = st_string

    if partial_overlap_dates
      q = q.or(en_string).or(on_or_before_start_date.and(on_or_after_end_date) )
    else
      q = q.and(en_string) 
    end

    q
  end



end
