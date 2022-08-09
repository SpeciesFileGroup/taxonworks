require 'rails_helper'
require 'export/dwca'

describe Export::Dwca, type: :model, group: :darwin_core do

  # specify "stores a compressed file in rails' temp directory" do
  #   path = Export::Dwca.get_archive
  #   expect(File.exists?(path)).to be_truthy
  #   File.delete(path)
  #   expect(path.to_s.index(Rails.root.join('tmp').to_s)).to eq(0)
  # end

  specify '.sample is ordered correctly #3' do
    13.times do
      FactoryBot.create(:valid_specimen)
    end

    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(10)
    m = Export::Dwca.index_metadata(CollectionObject, s)

    expect(m[:sample]).to contain_exactly(*s.collect{|a| a.to_global_id.to_s} )
  end

  specify 'index_metadata :sample is ordered correctly #2' do
    6.times do
      FactoryBot.create(:valid_specimen)
    end

    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(3)
    m = Export::Dwca.index_metadata(CollectionObject, s)

    expect(m[:sample]).to contain_exactly(*(s.collect{|a| a.to_global_id.to_s} - []) )
  end

  specify 'index_metadata .sample is ordered correctly (1 record)' do
    2.times do
      FactoryBot.create(:valid_specimen)
    end

    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(1)
    m = Export::Dwca.index_metadata(CollectionObject, s)
    expect(m[:sample]).to contain_exactly(*(s.collect{|a| a.to_global_id.to_s}) )
  end

  specify 'index_metadata .sample is ordered correctly (no records)' do
    FactoryBot.create(:valid_specimen)
    s = CollectionObject.where(project_id: Current.project_id).order(:id).limit(0)
    m = Export::Dwca.index_metadata(CollectionObject, s)
    expect(m[:sample]).to contain_exactly( )
  end
end
