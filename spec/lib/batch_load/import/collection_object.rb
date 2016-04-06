require 'rails_helper'

describe BatchLoad::Import::CollectionObjects, type: :model do

  let(:basic_headers) { ['PSUC', 'Species', 'OTU', 'Confirmed?', 'Collecting Event#',
                         'Date', 'Month', 'Day', 'Year', 'Verbatim Location',
                         'Latitude', 'Longitude', 'Error', 'Method'] }
  let(:basic_csv) {
    CSV.generate do |csv|
      csv << basic_headers
      csv << ['35614', 'Hetaerina americana', 'Hetaerina americana', '', '367',
              '8.18.1941', '8', '18', '1941',
              'Creek on Mary Shannon\'s place, Dallas, Texas']
      csv << ['37926', 'Hetaerina americana', 'Hetaerina americana', '', '2570',
              '7.30.1950', '7', '30', '1950',
              'Fish Hatchery, Kerrville, Tex.',
              '30.047433', '-99.140319', '10339 m', 'GEOLocate']
      csv
    end
  }

  let(:basic_csv_name_count) { 11 }

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }
  let(:parent_taxon_name) { FactoryGirl.create(:root_taxon_name) }
  let(:iczn_family) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: parent_taxon_name) }

  # TODO: rebuild these

end
