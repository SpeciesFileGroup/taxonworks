require 'rails_helper'

describe BatchLoad::Import::TaxonifiToTaxonworks, type: :model do

  let(:basic_headers) {  ["family", "genus", "species", "author", "year"] }
  let(:basic_csv) { 
    CSV.generate() do |csv|
      csv <<  basic_headers
      csv << ["Diapriidae", "Aus", "bus", "Smith", "1854"]
      csv << ["Scelionidae", "Bus", "cus", "Jones", "1854"]
      csv << ["Scelionidae", "Cus", nil, "Chapman", "1854"]
      csv << ["Scelionidae", "Bus", "dus", "Elroy", "1854"]
      csv << ["Playtgastridae", "Eus", "eus", nil, nil]
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
