require 'rails_helper'

describe DwcOccurrencesHelper, type: :helper do
  specify '#format_dwc_occurrence_attributes_for_ui leaves unformatted values alone' do
    attributes = helper.format_dwc_occurrence_attributes_for_ui({
      'basisOfRecord' => 'Occurrence'
    })

    expect(attributes['basisOfRecord']).to eq('Occurrence')
  end

  specify '#format_dwc_occurrence_attributes_for_ui truncates display-formatted values' do
    long_wkt = 'POLYGON((' + Array.new(30) { |i| "#{i} #{i}" }.join(', ') + '))'
    attributes = helper.format_dwc_occurrence_attributes_for_ui({
      'footprintWKT' => long_wkt,
      'basisOfRecord' => 'Occurrence'
    })

    expect(attributes['footprintWKT']).to end_with('...')
    expect(attributes['footprintWKT'].length).to be < long_wkt.length
  end
end
