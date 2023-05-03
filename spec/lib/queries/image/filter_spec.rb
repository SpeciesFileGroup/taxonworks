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

  specify '#collection_object_scope :observations' do
    t = FactoryBot.create(:valid_observation, observation_object: co)
    t.images << i1
    i2 # not this one
    q.collection_object_id = co.id
    q.collection_object_scope = [:observations]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_scope :type_material_observations' do
    t = FactoryBot.create(:valid_type_material)

    c = FactoryBot.create(:valid_observation, observation_object: t.collection_object)
    c.images << i1

    o.update!(taxon_name: t.protonym)
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:type_material_observations]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_scope :type_material' do
    t = FactoryBot.create(:valid_type_material)
    t.collection_object.images << i1
    o.update!(taxon_name: t.protonym)
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:type_material]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#coordinate_otu_ids' do
    o.update!(taxon_name: t3)

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)
    o1 = Otu.create!(taxon_name: t)

    q.otu_id = o1.id

    expect(q.coordinate_otu_ids).to contain_exactly(o.id, o1.id)
  end


  specify '#otu_scope :coordinate_otus, :collection_object_observations' do
    # First image, on valid
    o.update!(taxon_name: t3)
    TaxonDetermination.create!(otu: o, biological_collection_object: co)

    b = FactoryBot.create(:valid_observation, observation_object: co)
    b.images << i1

    # Second image, on invalid
    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)
    o1 = Otu.create!(taxon_name: t)
    td = TaxonDetermination.create!(otu: o1, biological_collection_object: Specimen.create!)

    c = FactoryBot.create(:valid_observation, observation_object: td.biological_collection_object)
    c.images << i2

    i3 # not this image

    # Map to invalid
    q.otu_id = o1.id

    q.otu_scope = [:coordinate_otus, :collection_object_observations]
    expect(q.coordinate_otu_ids).to contain_exactly(o.id, o1.id)
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :coordinate_otus, :otus' do
    o.images << i1

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)

    o.update(taxon_name: t3)

    o1 = Otu.create!(taxon_name: t)
    o1.images << i2

    i3 # not this one

    q.otu_id = [o.id]

    q.otu_scope = [:coordinate_otus, :otus]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :coordinate_otus, :collection_objects' do
    TaxonDetermination.create!(otu: o, biological_collection_object: co)
    co.images << i1

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)

    o.update(taxon_name: t3)
    o1 = Otu.create!(taxon_name: t)

    td = TaxonDetermination.create!(otu: o1, biological_collection_object: Specimen.create!)
    td.biological_collection_object.images << i2

    i3 # not this one

    q.otu_id = o.id

    q.otu_scope = [:coordinate_otus, :collection_objects]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :coordinate_otus, :otus' do
    o.images << i1

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)

    o.update(taxon_name: t3)
    o1 = Otu.create!(taxon_name: t)

    o1.images << i2

    i3 # not this one

    q.otu_id = o.id

    q.otu_scope = [:coordinate_otus, :otus]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :all' do
    b = FactoryBot.create(:valid_observation, observation_object: co)
    b.images << i1
    TaxonDetermination.create!(otu: o, biological_collection_object: co)

    o.images << i2

    i3 # not this one
    q.otu_id = o.id
    q.otu_scope = [:all]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :collection_object_observations' do
    b = FactoryBot.create(:valid_observation, observation_object: co)
    b.images << i1
    TaxonDetermination.create!(otu: o, biological_collection_object: co)
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:collection_object_observations]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_scope :otu_observations' do
    b = FactoryBot.create(:valid_observation, observation_object: o)
    b.images << i1
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:otu_observations]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_scope :otus' do
    o.images << i1
    FactoryBot.create(:valid_otu)
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:otus]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_scope :collection_objects' do
    t = TaxonDetermination.create!(otu: o, biological_collection_object: co)
    co.images << i1
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:collection_objects]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

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

