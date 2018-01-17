module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  def parse_label(label)
    retval = Utilities::Geo.hunt_wrapper(label)
    retval
  end

  def make_method_headers
    list         = Utilities::Geo::REGEXP_COORD
    selector_row = ""
    list.keys.each { |kee|
      selector_row += content_tag(:th, kee.to_s.upcase,
                                  data: {help: Utilities::Geo::REGEXP_COORD[kee][:hlp]})
    }
    selector_row.html_safe
  end


  # @param [Array] filters must be array of symbols from Utilities::Geo::REGEXP_COORD
  def make_selected_method_boxes(filters = Utilities::Geo::REGEXP_COORD.keys)
    list    = Utilities::Geo::REGEXP_COORD
    box_row = ""
    list.keys.each { |kee|
      checked = filters.include?(kee)
      box_row += content_tag(:td, check_box_tag("filters[]", kee.to_s, checked), align: 'center')
    }
    box_row.html_safe
  end

  def make_rows(label, filters)
    return nil if label.nil?
    tests = Utilities::Geo.hunt_wrapper(label, filters)
    tests.keys.collect.with_index do |kee, dex|
      trial  = tests[kee]
      method = trial.delete(:method)
      next if trial.blank?
      content_tag(:tr, class: :extract_row) do
        content_tag(:td, method, align: 'center') +
          # content_tag(:td, kee == method ? '' : kee) +
          content_tag(:td, trial[:piece], class: :piece_value, align: 'center') +
          content_tag(:td, trial[:lat], class: :latitude_value, align: 'center') +
          content_tag(:td, trial[:long], class: :longitude_value, align: 'center') +
          content_tag(:td, radio_button_tag('select', dex, false, class: :select_lat_long), align: 'center')
      end
    end.join.html_safe
  end

  # @param [String] pieces is either piece, or lat, long
  # @param [Scope] collection is a scope of CollectingEvent
  def make_lat_long_matching_table(*pieces, collection)
    columns = ['CEID', 'Match', 'Verbatim Lat', 'Verbatim Long',
               'Decimal lat', 'Decimal long', 'Is georeferenced?', 'Select']

    thead = content_tag(:thead) do
      content_tag(:tr) do
        columns.collect { |column| concat content_tag(:th, column) }.join.html_safe
      end
    end

    tbody = content_tag (:tbody) do
      collection.collect { |item|
        content_tag (:tr) do
          item_data = ''
          no_georef = false
          columns.collect.with_index { |column, dex|
            options = {align: 'center'}
            case dex
              when 0 #'CEID'
                item_data = link_to(item.id, item)
              when 1 #'Match'
                item_data      = pieces.join(' ')
                options[:data] = {help: item.verbatim_label}
              when 2 #'Verbatim Lat'
                item_data = item.verbatim_latitude
              when 3 #'Verbatim Long'
                item_data = item.verbatim_longitude
              when 4 #'Decimal lat'
                item_data = item.latitude
              when 5 #'Decimal long'
                item_data = item.longitude
              when 6 #'Is georeferenced?'
                if item.georeferences.any?
                  item_data = 'yes'
                  no_georef = true
                else
                  item_data = 'no'
                end
              when 7 #'Select'
                # check_box_tag(name, value = "1", checked = false, options = {}) public
                options_for         = {disabled: no_georef}
                options_for[:class] = 'selectable_select' unless no_georef
                item_data           = check_box_tag('selected[]', item.id, false, options_for)
            end
            concat content_tag(:td, item_data, options)
          }.to_s.html_safe
        end
      }.join().html_safe
    end

    content_tag(:table, thead.concat(tbody), {id: 'matching_table', border: '1', align: 'center'}).html_safe
  end

  def test_lat
    @collecting_event.verbatim_latitude unless @collecting_event.nil?
  end

  def test_long
    @collecting_event.verbatim_longitude unless @collecting_event.nil?
  end

  def show_ce_vl(collecting_event)
    message = 'No collecting event available.'
    unless collecting_event.nil?
      message = collecting_event.verbatim_label
    end
    collecting_event_label_tag(message)
  end

  def parse_lat_long_skip(current_collecting_event_id, filters)
    # TODO: Now this has to be bound to next hit
    # filters = Utilities::Geo::REGEXP_COORD.keys
    next_id = Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: current_collecting_event_id,
      filters:             filters).all.with_project_id(sessions_current_project_id).first.try(:id)
    if next_id
      button_tag('Skip to next record',
                 {value: 'skip', id: 'skip'})
      # link_to('Skip to next record', collecting_event_lat_long_task_path(collecting_event_id: next_id))
    else
      content_tag(:span, 'no more matches')
    end + button_tag('Re-evaluate',
                     {value: 're_eval', id: 're_eval'})
  end

  def scan_c_e
    pile = Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: 0,
      filters:             DEFAULT_SQL_REGEXS).all.with_project_id(sessions_current_project_id).order(:id)
    pile.each { |c_e|
      trials = Utilities::Geo.hunt_lat_long_full(c_e.verbatim_label)
      puts(c_e.id)
    }
    pile
  end

end
