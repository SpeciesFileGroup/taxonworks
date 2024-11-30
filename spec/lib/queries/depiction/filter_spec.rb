require 'rails_helper'

describe Queries::Depiction::Filter, type: :model, group: [:images] do


  let(:qi) { Queries::Image::Filter.new({}) }

  let(:q) { Queries::Depiction::Filter.new({}) }


  let(:i1) { FactoryBot.create(:tiny_random_image) }
  let(:i2) { FactoryBot.create(:tiny_random_image) }
  let(:i3) { FactoryBot.create(:tiny_random_image) }

  let(:o) { Otu.create(name: 'o1') }
  let(:co) { Specimen.create!  }
  let(:ce) { CollectingEvent.create!(verbatim_label: 'Test') }

  let(:t1) { FactoryBot.create(:root_taxon_name) }
  let(:t2) { Protonym.create(name: 'Aus', parent: t1, rank_class: Ranks.lookup(:iczn, :genus) ) }
  let(:t3) { Protonym.create(name: 'bus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) ) }

  specify '#collection_object_scope :observations' do
    t = FactoryBot.create(:valid_observation, observation_object: co)
    t.images << i1

    co.images << i2

    qi.collection_object_id = co.id
    qi.collection_object_scope = [:observations]

    q.image_query = ::Queries::Image::Filter.new( collection_object_id: co.id, collection_object_scope: [:observations] )

    expect(q.all.first).to eq(t.depictions.first)
  end

  specify 'otu_scope' do
    o.images << i1
    co.images << i2

    q.otu_id =  o.id

    q.otu_scope = [:all]

    expect(q.all).to contain_exactly(o.depictions.first)
  end



end
