require 'rails_helper'

describe Queries::Image::Filter, type: :model, group: [:images] do

  let(:q) { Queries::Image::Filter.new({}) }

  let(:i1) { FactoryBot.create(:valid_image) }
  let(:i2) { FactoryBot.create(:valid_image) }
  let(:i3) { FactoryBot.create(:valid_image) }

  let(:o) { Otu.create(name: 'o1') }
  let(:co) { Specimen.create!  }
  let(:ce) { CollectingEvent.create!(verbatim_label: 'Test') }

  let(:t1) { FactoryBot.create(:root_taxon_name) }
  let(:t2) { Protonym.create(name: 'Aus', parent: t1, rank_class: Ranks.lookup(:iczn, :genus) ) }
  let(:t3) { Protonym.create(name: 'bus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) ) }

  specify '#otu_id one' do
    o.images << i1
    q.otu_id = o.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_id array' do
    o.images << i1
    q.otu_id = [o.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#collection_object_id id' do
    co.images << i1
    q.collection_object_id = co.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#collection_object_id array' do
    co.images << i1
    q.collection_object_id = [co.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#collecting_event_id id' do
    ce.images << i1
    q.collecting_event_id = ce.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#collecting_event_id array' do
    ce.images << i1
    q.collecting_event_id = [ce.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#image_id id' do
    q.image_id = i1.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#image_id array' do
    q.image_id = [i1.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#image_id array nontrivial' do
    q.image_id = [i1.id, i3.id, i2.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id, i3.id)
  end

  specify '#biocuration_class_id id' do
    co.images << i1
    a = FactoryBot.create(:valid_biocuration_classification, biological_collection_object: co)
    q.biocuration_class_id = a.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#biocuration_class_id array' do
    co.images << i1
    a = FactoryBot.create(:valid_biocuration_classification, biological_collection_object: co)
    q.biocuration_class_id = [a.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#sled_image_id array' do
    a = FactoryBot.create(:valid_sled_image, image: i1)
    q.sled_image_id =  [a.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#sqed_image_id array' do
    a = FactoryBot.create(:valid_sqed_depiction, image: i1)
    q.sqed_depiction_id = [a.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#depiction false' do
    i1
    i2
    q.depiction = false
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#depiction true' do
    q.depiction = true
    o.images << i1
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#taxon_name_id id' do
    o.update!(taxon_name: t3)
    o.images << i1
    q.taxon_name_id = t2.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#taxon_name_id array, Otu' do
    o.update!(taxon_name: t3)
    o.images << i1
    q.taxon_name_id = [t2.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#taxon_name_id array, CollectionObject' do
    o.update!(taxon_name: t3)
    co.images << i1
    co.otus << o
    q.taxon_name_id = [t2.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#taxon_name_id, #ancestor_id_target' do
    # Collection object
    o.update!(taxon_name: t3)
    co.images << i1
    co.otus << o

    # Otu
    o.images << i2

    q.taxon_name_id = [t2.id]
    q.ancestor_id_target = 'CollectionObject'

    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify 'some together' do
    # Collection object
    o.update!(taxon_name: t3)
    co.images << i1
    co.otus << o

    # Otu
    o.images << i2

    q.taxon_name_id = [t2.id]
    q.depiction = true
    q.image_id = [i1.id]

    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

end

