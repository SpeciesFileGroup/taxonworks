require 'rails_helper'

describe CollectingEvent, type: :model, group: [:geo, :collecting_event] do

  let(:collecting_event) { CollectingEvent.new }

  let!(:never_found) { CollectingEvent.create!(verbatim_label: 'Nope') }
  let(:county) { FactoryBot.create(:valid_geographic_area_stack) }
  let(:state) { county.parent }
  let(:country) { state.parent }

  #       a          b           c          d          e
  # ------|----------|-----------|----------|----------|
  #   1800-1-1  1900-12-31   2004-2-29   2010-12-1   Now() ?!
  #
  let(:a) { '1800-1-1' }
  let(:b) { '1900-12-31' }
  let(:c) { '2004-2-29' }
  let(:d) { '2010-12-1' }
  let(:e) { Time.zone.today.strftime('%Y-%m-%d') }

  let(:s1) { '2000--' }
  let(:s2) { '2000-2-' }
  let(:s3) { '2000-2-' }
  let(:s4) { '2000-2-1' }
  let(:s5) { '-2-1' }

  let(:i1) { '--1' }
  let(:i2) { '2000--1' }

  def parse_stubs(start_data, end_data)
    start_data ||= '--'
    end_data ||= '--'

    sy, sm, sd = start_data.split('-')
    ey, em, ed = end_data.split('-')
    {
      start_date_year: sy,
      start_date_month: sm,
      start_date_day: sd,
      end_date_year: ey,
      end_date_month: em,
      end_date_day: ed
    }
  end

  # TEMPLATE
  # context 'some test' d
  #   let(:search_start) { a }
  #   let(:search_end) { c }
  #
  #   let(:ce1) { CollectingEvent.new(parse_stubs(s1, s2)) }
  #   let(:cen) {  }

  #   specify '' do
  #     expect(CollectingEvent.in_date_range(search_start,search_end)).to contain_exactly(ce1,ce2)
  #   end
  # end

  context 'chaining scopes' do
    let!(:ce1) { CollectingEvent.create!(parse_stubs(a, b).merge(verbatim_label: "#{a} -- #{b}")) }
    let!(:ce2) { CollectingEvent.create!(parse_stubs(c, d).merge(verbatim_label: "#{c} -- #{d}")) }

    let(:params) {
      {search_start_date: a, search_end_date: b}
    }

    specify 'returns one (strict), ordered' do
      expect(CollectingEvent.in_date_range(params.merge(partial_overlap: 'OfF')).order(:id)).to contain_exactly(ce1)
    end

    specify 'using just the sql, ordered' do
      q = Queries::CollectingEvent::Filter.new(start_date: '2015-1-1', end_date: '2015-1-1', partial_overlap_dates: false) 
      expect(CollectionObject.joins(:collecting_event).where(q.between_date_range.to_sql).where(project_id: 99).order(:id).count).to eq(0)
    end
  end

  context 'combined' do
    #       a     b
    # ------*-----*------
    #       a     b            yes
    #                 c     d   no
    #

    let!(:ce1) { CollectingEvent.create!(parse_stubs(a, b).merge(verbatim_label: "#{a} -- #{b}")) }
    let!(:ce2) { CollectingEvent.create!(parse_stubs(c, d).merge(verbatim_label: "#{c} -- #{d}")) }

    let(:params) {
      {search_start_date: a, search_end_date: b}
    }

    specify 'returns one (strict)' do
      expect(CollectingEvent.in_date_range(params.merge(partial_overlap: 'OfF'))).to contain_exactly(ce1)
    end

    specify 'returns one (lenient)' do
      expect(CollectingEvent.in_date_range(params.merge(partial_overlap: 'on'))).to contain_exactly(ce1)
    end

  end

  context 'combined (strict)' do
    #       a     c
    # ------*-----*------
    #       a     c      yes
    #          b     d   no
    #

    let!(:ce1) { CollectingEvent.create!(parse_stubs(a, c).merge(verbatim_label: "#{a} -- #{c}")) }
    let!(:ce2) { CollectingEvent.create!(parse_stubs(b, d).merge(verbatim_label: "#{b} -- #{d}")) }

    let(:params) {
      {search_start_date: a, search_end_date: c, partial_overlap: 'OfF'}
    }

    specify 'returns one' do
      expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
    end
  end


  context 'combined (lenient)' do
    #       a     c
    # ------*-----*------
    #       a     c      yes
    #          b     d   no
    #

    let!(:ce1) { CollectingEvent.create!(parse_stubs(a, c).merge(verbatim_label: "#{a} -- #{c}")) }
    let!(:ce2) { CollectingEvent.create!(parse_stubs(b, c).merge(verbatim_label: "#{b} -- #{c}")) }

    let(:params) {
      {search_start_date: a, search_end_date: c, partial_overlap: 'on'}
    }

    specify 'returns both' do
      expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1, ce2)
    end
  end


  context 'partial_overlap OFF (strict)' do

    #       a        d
    #       *        *
    # ------s--------e---
    context 'search range completely inside record start/end' do
      let(:params) {
        {search_start_date: a, search_end_date: d, partial_overlap: 'OfF'}
      }

      let!(:ce1) { CollectingEvent.create!(parse_stubs(a, d).merge(verbatim_label: "#{a} -- #{d}")) }

      specify 'returns none' do
        expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
      end
    end

    #       a  b  c  d
    # ------s--*--*--e---
    context 'search range completely inside record start/end' do
      let(:params) {
        {search_start_date: b, search_end_date: c, partial_overlap: 'OfF'}
      }

      let!(:ce1) { CollectingEvent.create!(parse_stubs(a, d).merge(verbatim_label: "#{a} -- #{d}")) }

      specify 'returns none' do
        expect(CollectingEvent.in_date_range(params)).to contain_exactly()
      end
    end

    context 'search range completely/partially surround target range' do

      #    a  b   c   d
      # ---*--s---e---*
      context 'search range completely encloses record start/end' do
        let(:params) {
          {search_start_date: a, search_end_date: d, partial_overlap: 'OFF'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(b, c).merge(verbatim_label: "#{b} -- #{c}")) }

        specify 'returns one' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
        end
      end

      #    a  b  c  d
      # ---*--s--*--e---
      context 'search range encloses record start date, but not end' do
        let(:params) {
          {search_start_date: a, search_end_date: c, partial_overlap: 'off'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(b, d).merge(verbatim_label: "#{b} -- #{d}")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end

      #    a  b  c
      # ---*--s--*------
      context 'search range encloses record start date, record end not provided' do
        let(:params) {
          {search_start_date: a, search_end_date: c, partial_overlap: 'off'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(b, nil).merge(verbatim_label: "#{b} -- nil")) }

        specify 'returns one' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
        end
      end
    end

    context 'search range surrounds one target' do

      #       a  b  c  d
      # ------s--*--e--*---
      context 'search range encloses record end, but not record start' do
        let(:params) {
          {search_start_date: b, search_end_date: d, partial_overlap: 'off'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(a, c).merge(verbatim_label: "#{a} -- #{c}")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end

    end

    context 'search params surround neither target' do
      #       a  b  c  d
      # ------s--*--*--e---
      context 'search range enclosed by record range' do
        let(:params) {
          {search_start_date: b, search_end_date: c, partial_overlap: 'off'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(a, d).merge(verbatim_label: "#{a} -- #{d}")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end

      #  a b     c    d
      # -*-*-----s----e-----
      context 'search range and record range completely seperate' do
        let(:params) {
          {search_start_date: a, search_end_date: b, partial_overlap: 'off'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(c, d).merge(verbatim_label: "#{c} -- #{d}")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end

      #  a b     c
      # -*-*-----s----------
      context 'search range and record start completely separate, no record end provided' do
        let(:params) {
          {search_start_date: a, search_end_date: b, partial_overlap: 'off'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(c, nil).merge(verbatim_label: "#{c} -- nil")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end
    end
  end


  # ----

  context 'partial_overlap ON (lenient)' do


    #       a        d
    #       *        *
    # ------s--------e---
    context 'search range completely inside record start/end' do
      let(:params) {
        {search_start_date: a, search_end_date: d, partial_overlap: 'on'}
      }

      let!(:ce1) { CollectingEvent.create!(parse_stubs(a, d).merge(verbatim_label: "#{a} -- #{d}")) }

      specify 'returns none' do
        expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
      end
    end


    context 'search params completely surround target' do

      #    a  b   c   d
      # ---*--s---e---*
      context 'surrounding start and end date' do
        let(:params) {
          {search_start_date: a, search_end_date: d, partial_overlap: 'on'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(b, c).merge(verbatim_label: "#{b} -- #{c}")) }

        specify 'returns' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
        end
      end

      #    a  b  c  d
      # ---*--s--*--e---
      context 'surrounding start date, end not provided' do
        let(:params) {
          {search_start_date: a, search_end_date: c, partial_overlap: 'on'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(b, d).merge(verbatim_label: "#{b} -- #{d}")) }

        specify 'returns' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
        end
      end

      #    a  b  c
      # ---*--s--*------
      context 'surrounding start date, end not provided' do
        let(:params) {
          {search_start_date: a, search_end_date: c, partial_overlap: 'on'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(b, nil).merge(verbatim_label: "#{b} -- nil")) }

        specify 'returns' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
        end
      end
    end

    context 'search range surrounds only end date of target' do

      #       a  b  c  d
      # ------s--*--e--*---
      context 'search range encloses record end' do
        let(:params) {
          {search_start_date: b, search_end_date: d, partial_overlap: 'on'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(a, c).merge(verbatim_label: "#{a} -- #{c}")) }

        specify 'returns one' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
        end
      end
    end

    #       a  b  c  d
    # ------s--*--*--e---
    context 'record range completely encloses search start/end' do
      let(:params) {
        {search_start_date: b, search_end_date: c, partial_overlap: 'on'}
      }

      let!(:ce1) { CollectingEvent.create!(parse_stubs(a, d).merge(verbatim_label: "#{a} -- #{d}")) }

      specify 'returns one' do
        expect(CollectingEvent.in_date_range(params)).to contain_exactly(ce1)
      end
    end

    context 'search range surrounds neither target' do
      #  a b     c    d
      # -*-*-----s----e-----
      context 'record range completely outside search start/end' do
        let(:params) {
          {search_start_date: a, search_end_date: b, partial_overlap: 'on'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(c, d).merge(verbatim_label: "#{c} -- #{d}")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end

      #  a b     c
      # -*-*-----s----------
      context 'record outside search start/end, record end not provided' do
        let(:params) {
          {search_start_date: a, search_end_date: b, partial_overlap: 'on'}
        }

        let!(:ce1) { CollectingEvent.create!(parse_stubs(c, nil).merge(verbatim_label: "#{c} -- nil")) }

        specify 'returns none' do
          expect(CollectingEvent.in_date_range(params)).to contain_exactly()
        end
      end
    end
  end

  # --- End stub tests ---

  # Somehwhat helper like, but needed for compute/indexing etc. Probably should all go to helper module
  context 'date formatting' do
    specify '#has_start_date?' do
      a = CollectingEvent.new(start_date_year: 2010, start_date_month: 2, start_date_day: 1)
      expect(a.has_start_date?).to be_truthy 
    end

    specify '#has_end_date?' do
      a = CollectingEvent.new(end_date_year: 2010, end_date_month: 2, end_date_day: 1)
      expect(a.has_end_date?).to be_truthy 
    end

    specify '#some_end_date?' do
      a = CollectingEvent.new(end_date_month: 2, end_date_day: 1)
      expect(a.some_end_date?).to be_truthy 
    end

    specify '#some_start_date?' do
      a = CollectingEvent.new(start_date_year: 2010)
      expect(a.some_start_date?).to be_truthy 
    end
    
    specify '#some_start_date?' do
      a = CollectingEvent.new()
      expect(a.some_start_date?).to be_falsey
    end

    specify '#start_date_string 1' do
      a = CollectingEvent.new(start_date_year: 2010, start_date_month: 2)
      expect(a.start_date_string).to eq('2010/02/??')
    end 

    specify '#start_date_string 2' do
      a = CollectingEvent.new(start_date_month: 2)
      expect(a.start_date_string).to eq('????/02/??')
    end 

    specify '#end_date_string 1' do
      a = CollectingEvent.new(end_date_year: 2010, end_date_month: 2)
      expect(a.end_date_string).to eq('2010/02/??')
    end
  end

  # Attribute validation
  specify 'start_date_year is valid as 4 digit integer' do
    # You can also pass a string, casting is automatic
    collecting_event.start_date_year = 1942
    collecting_event.valid?
    expect(collecting_event.errors[:start_date_year].size).to eq(0)
  end

  specify 'start_date_year is invalid as 3 digit integer' do
    collecting_event.start_date_year = '194'
    collecting_event.valid?
    expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
  end

  specify 'start_date_year is invalid as when > 5 years from the future' do
    collecting_event.start_date_year = (Time.now.year + 6)
    collecting_event.valid?
    expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
  end

  specify 'start_date_year is invalid when less than 1000' do
    collecting_event.start_date_year = 999
    collecting_event.valid?
    expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
  end

  specify 'end_date_year is valid as 4 digit integer' do
    # You can also pass a string, casting is automatic
    collecting_event.end_date_year = 1942
    collecting_event.valid?
    expect(collecting_event.errors[:end_date_year]).to eq([])
  end

  specify 'end_date_year is invalid as 3 digit integer' do
    collecting_event.end_date_year = '194'
    collecting_event.valid?
    expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
  end

  specify 'end_date_year is invalid as when > 5 years from the future' do
    collecting_event.end_date_year = Time.now.year + 6
    collecting_event.valid?
    expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
  end

  specify 'end_date_year is invalid when less than 1000' do
    collecting_event.end_date_year = 999
    collecting_event.valid?
    expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
  end

  specify 'start_date_month is invalid when not included in 1-12' do
    ['ab', 'February', 13, 0].each do |m|
      collecting_event.start_date_month = m
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_month)).to be_truthy
    end
  end

  specify 'start_date_day is invalid when not an integer' do
    collecting_event.start_date_day = 'a'
    collecting_event.valid?
    expect(collecting_event.errors.include?(:start_date_day)).to be_falsey
  end

  specify 'start_date_day is value bound by month' do
    collecting_event.start_date_year  = '1945' # requires year for leaps
    collecting_event.start_date_month = '2'
    collecting_event.start_date_day   = '30'
    collecting_event.valid?
    expect(collecting_event.errors.include?(:start_date_day)).to be_truthy
  end

  specify 'start_date_month is invalid when nil AND start_date_day provided' do
    collecting_event.start_date_day = 1
    collecting_event.valid?
    expect(collecting_event.errors.include?(:start_date_month)).to be_truthy
  end

  specify 'end_date_month is invalid when not included in 1-12' do
    ['ab', 'February', 13, 0].each do |m|
      collecting_event.end_date_month = m
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_month)).to be_truthy
    end
  end

  specify 'end_date_day is invalid when not an integer' do
    collecting_event.end_date_day = 'a'
    collecting_event.valid?
    expect(collecting_event.errors.include?(:end_date_day)).to be_falsey
  end

  specify 'end_date_day is value bound by month' do
    collecting_event.end_date_year  = '1945' # requires year for leaps
    collecting_event.end_date_month = '2'
    collecting_event.end_date_day   = '30'
    collecting_event.valid?
    expect(collecting_event.errors.include?(:end_date_day)).to be_truthy
  end

  specify 'end_date_month is invalid when nil AND end_date_day provided' do
    collecting_event.end_date_day = 1
    collecting_event.valid?
    expect(collecting_event.errors.include?(:end_date_month)).to be_truthy
  end

  specify 'end date is > start date when both are provided' do
    message                           = 'End date is earlier than start date.'
    collecting_event.start_date_day   = 2
    collecting_event.start_date_month = 1
    collecting_event.start_date_year  = 1

    collecting_event.end_date_day   = 1
    collecting_event.end_date_month = 1
    collecting_event.end_date_year  = 1

    expect(collecting_event.valid?).to be_falsey
    expect(collecting_event.errors[:base].include?(message)).to be_truthy
  end

  specify 'end date is > start date when both are provided' do
    message                           = 'End date is earlier than start date.'
    collecting_event.start_date_day   = '26'
    collecting_event.start_date_month = '6'
    collecting_event.start_date_year  = '1970'

    collecting_event.end_date_day = '24'
    collecting_event.end_date_month = '7'
    collecting_event.end_date_year  = '1970'

    expect(collecting_event.valid?).to be_truthy
    expect(collecting_event.errors[:base].include?(message)).to be_falsey
  end

  specify 'end date without start date' do
    message                         = 'End date without start date.'
    collecting_event.end_date_day   = 1
    collecting_event.end_date_month = 1
    collecting_event.end_date_year  = 1789

    expect(collecting_event.valid?).to be_falsey
    expect(collecting_event.errors[:base].include?(message)).to be_truthy
  end




end
