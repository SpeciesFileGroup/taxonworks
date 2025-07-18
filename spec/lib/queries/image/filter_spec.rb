require 'rails_helper'

describe Queries::Image::Filter, type: :model, group: [:images] do

  let(:q) { Queries::Image::Filter.new({}) }

  let(:i1) { FactoryBot.create(:tiny_random_image) }
  let(:i2) { FactoryBot.create(:tiny_random_image) }
  let(:i3) { FactoryBot.create(:tiny_random_image) }

  let(:o) { Otu.create(name: 'o1') }
  let(:co) { Specimen.create!  }
  let(:ce) { CollectingEvent.create!(verbatim_label: 'Test') }
  let(:fo) { FactoryBot.create(:valid_field_occurrence, otu: o) }

  let(:t1) { FactoryBot.create(:root_taxon_name) }
  let(:t2) { Protonym.create(name: 'Aus', parent: t1, rank_class: Ranks.lookup(:iczn, :genus) ) }
  let(:t3) { Protonym.create(name: 'bus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) ) }

  specify '#params, ActionController::Parameters, array' do
    ce.images << i1
    h = {collecting_event_query: {collecting_event_id: [ce.id]}}
    p = ActionController::Parameters.new( h  )
    query = Queries::Image::Filter.new(p)
    expect(query.params).to eq(h)
  end

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

  specify '#otu_scope :coordinate_otus, :collection_object_observations' do
    # First image, on valid
    o.update!(taxon_name: t3)
    TaxonDetermination.create!(otu: o, taxon_determination_object: co)

    b = FactoryBot.create(:valid_observation, observation_object: co)
    b.images << i1

    # Second image, on invalid
    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)
    o1 = Otu.create!(taxon_name: t)
    td = TaxonDetermination.create!(otu: o1, taxon_determination_object: Specimen.create!)

    c = FactoryBot.create(:valid_observation, observation_object: td.taxon_determination_object)
    c.images << i2

    i3 # not this image

    # Map to invalid
    q.otu_id = o1.id

    q.otu_scope = [:coordinate_otus, :collection_object_observations]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :coordinate_otus, :otus' do
    o.images << i1

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)

    o.update!(taxon_name: t3)

    o1 = Otu.create!(taxon_name: t)
    o1.images << i2

    i3 # not this one

    q.otu_id = [o.id]

    q.otu_scope = [:coordinate_otus, :otus]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :coordinate_otus, :collection_objects' do
    TaxonDetermination.create!(otu: o, taxon_determination_object: co)
    co.images << i1

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)

    o.update!(taxon_name: t3)
    o1 = Otu.create!(taxon_name: t)

    td = TaxonDetermination.create!(otu: o1, taxon_determination_object: Specimen.create!)
    td.taxon_determination_object.images << i2

    i3 # not this one

    q.otu_id = o.id

    q.otu_scope = [:coordinate_otus, :collection_objects]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :coordinate_otus, :otus' do
    o.images << i1

    t = Protonym.create(name: 'cus', parent: t2, rank_class: Ranks.lookup(:iczn, :species) )
    t.synonymize_with(t3)

    o.update!(taxon_name: t3)
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
    TaxonDetermination.create!(otu: o, taxon_determination_object: co)

    o.images << i2

    i3 # not this one
    q.otu_id = o.id
    q.otu_scope = [:all]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#otu_scope :collection_object_observations' do
    b = FactoryBot.create(:valid_observation, observation_object: co)
    b.images << i1
    TaxonDetermination.create!(otu: o, taxon_determination_object: co)
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
    t = TaxonDetermination.create!(otu: o, taxon_determination_object: co)
    co.images << i1
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:collection_objects]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#otu_scope :field_occurrences' do
    fo.images << i1
    i2 # not this one
    q.otu_id = o.id
    q.otu_scope = [:field_occurrences]
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

  specify '#collection_object_scope :observations' do
    d = Descriptor::Working.create!(name: 'working')
    obs = Observation::Working.create!(
      descriptor: d, observation_object: co, description: 'mostly fuzz'
    )
    obs.images << i1
    co.images << i2
    i3 # not this one
    q.collection_object_id = co.id
    q.collection_object_scope = :observations
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#field_occurrence_scope :collecting_event' do
    fo.collecting_event.images << i1
    fo.images << i2 # not this one
    i3 # not this one
    q.field_occurrence_id = fo.id
    q.field_occurrence_scope = :collecting_events
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#field_occurrence_scope [:field_occurrence, :observations]' do
    d = Descriptor::Working.create!(name: 'working')
    obs = Observation::Working.create!(
      descriptor: d, observation_object: fo, description: 'mostly wuzz'
    )
    obs.images << i1
    fo.images << i2
    i3 # not this one
    q.field_occurrence_id = fo.id
    q.field_occurrence_scope = [:observations, :field_occurrences]
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#collecting_event_id id' do
    ce.images << i1
    q.collecting_event_query = ::Queries::CollectingEvent::Filter.new(collecting_event_id: ce.id)
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#collecting_event_id array' do
    ce.images << i1
    q.collecting_event_query = ::Queries::CollectingEvent::Filter.new(collecting_event_id: [ce.id])
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
    a = FactoryBot.create(:valid_biocuration_classification, biocuration_classification_object:  co)
    q.biocuration_class_id = a.id
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#biocuration_class_id array' do
    co.images << i1
    a = FactoryBot.create(:valid_biocuration_classification, biocuration_classification_object: co)
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

  specify '#depictions false' do
    i1
    i2
    q.depictions = false
    expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
  end

  specify '#depiction true' do
    q.depictions = true
    o.images << i1
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#depiction_object_type FieldOccurrence' do
    fo.images << i1
    co.images << i2 # not i2
    q.depiction_object_type = 'FieldOccurrence'
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

  specify '#taxon_name_id array, FieldOccurrence' do
    o.update!(taxon_name: t3)
    fo.images << i1
    i2 # not this
    q.taxon_name_id = [t1.id]
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify '#taxon_name_id, #taxon_name_id_target' do
    # Collection object
    o.update!(taxon_name: t3)
    co.images << i1
    co.otus << o

    # Otu
    o.images << i2

    q.taxon_name_id = [t2.id]
    q.taxon_name_id_target = 'CollectionObject'

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
    q.depictions = true
    q.image_id = [i1.id]

    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify 'source_id' do
    s1 = FactoryBot.create(:valid_source, title: 'pickles')
    s2 = FactoryBot.create(:valid_source, title: 'ginger')
    i1.citations << Citation.new(source: s1)

    q.source_id = [s1.id, s2.id]

    i2 # not this one
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify 'depiction_caption exact' do
    Depiction.create!(depiction_object: o, image: i1, caption: 'rain')
    Depiction.create!(depiction_object: o, image: i2, caption: 'spraingle')

    q.depiction_caption = 'rain'
    q.depiction_caption_exact = true

    i3 # not this one
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify 'depiction_caption substring' do
    Depiction.create!(depiction_object: o, image: i1, caption: 'bonkers')
    Depiction.create!(depiction_object: o, image: i2, caption: 'Kevin')

    q.depiction_caption = 'onk'

    i3 # not this one
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  specify 'depiction_caption match across whitespace' do
    Depiction.create!(depiction_object: o, image: i1, caption: 'bonkers wint baloo')
    Depiction.create!(depiction_object: o, image: i2, caption: 'cuckoo')

    q.depiction_caption = 'onk aloo'

    i3 # not this one
    expect(q.all.map(&:id)).to contain_exactly(i1.id)
  end

  context 'attributions' do
    let!(:attribution1) { FactoryBot.create(:valid_attribution,
      attribution_object: i1) }

    let(:attribution2) { FactoryBot.create(:valid_attribution,
      attribution_object: i2) }

    let(:attribution3) { FactoryBot.create(:valid_attribution,
      attribution_object: i3) }

    let(:p1) { FactoryBot.create(:valid_person) }
    let(:p2) { FactoryBot.create(:valid_person) }

    let(:o1) { FactoryBot.create(:valid_organization) }
    let(:o2) { FactoryBot.create(:valid_organization) }

    specify 'creator' do
      Role.create!(person: p1, type: 'AttributionCreator',
        role_object: attribution1)

      q.creator_id = p1.id

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'two creators \'and\'' do
      Role.create!(person: p1, type: 'AttributionCreator',
        role_object: attribution1)

      Role.create!(person: p2, type: 'AttributionCreator',
        role_object: attribution1)

      q.creator_id = [p1.id, p2.id]
      q.creator_id_all = true

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'two creators \'and\' 2' do
      Role.create!(person: p1, type: 'AttributionCreator',
        role_object: attribution1)

      q.creator_id = [p1.id, p2.id]
      q.creator_id_all = true

      i2 # not this one
      expect(q.all.map(&:id)).to be_empty
    end

    specify 'two creators \'or\'' do
      Role.create!(person: p1, type: 'AttributionCreator',
        role_object: attribution1)

      q.creator_id = [p1.id, p2.id]
      q.creator_id_all = false

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'editor' do
      Role.create!(person: p1, type: 'AttributionEditor',
        role_object: attribution1)

      q.editor_id = p1.id

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'owner person or' do
      Role.create!(person: p1, type: 'AttributionOwner',
        role_object: attribution1)

      Role.create!(organization: o1, type: 'AttributionOwner',
        role_object: attribution1)

      q.owner_id = p1.id
      q.creator_id_all = false

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'owner organization or' do
      Role.create!(person: p1, type: 'AttributionOwner',
        role_object: attribution1)

      Role.create!(organization: o1, type: 'AttributionOwner',
        role_object: attribution1)

      q.owner_organization_id = o1.id
      q.creator_id_all = false

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'owner person AND organization' do
      Role.create!(person: p1, type: 'AttributionOwner',
        role_object: attribution1)

      Role.create!(organization: o1, type: 'AttributionOwner',
        role_object: attribution1)

      q.owner_id = p1.id
      q.owner_organization_id = o1.id
      q.creator_id_all = true

      i2 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id)
    end

    specify 'owner person AND organization 2' do
      Role.create!(person: p1, type: 'AttributionOwner',
        role_object: attribution1)

      q.owner_id = p1.id
      q.owner_organization_id = o1.id
      q.owner_id_all = true

      i2 # not this one
      expect(q.all.map(&:id)).to be_empty
    end

    specify 'copyright holder person or' do
      Role.create!(person: p1, type: 'AttributionOwner',
        role_object: attribution1)

      Role.create!(person: p1, type: 'AttributionOwner',
        role_object: attribution2)

      q.owner_id = p1.id
      q.creator_id_all = false

      i3 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
    end

    specify 'copyright holder organization or' do
      Role.create!(organization: o1, type: 'AttributionOwner',
        role_object: attribution1)

      Role.create!(organization: o2, type: 'AttributionOwner',
        role_object: attribution2)

      q.owner_organization_id = [o1.id, o2.id]
      q.creator_id_all = false

      i3 # not this one
      expect(q.all.map(&:id)).to contain_exactly(i1.id, i2.id)
    end

    specify 'license' do
      attribution1.license = 'Attribution-ShareAlike'
      attribution2.license = 'Attribution-NoDerivs'
      attribution1.save!
      attribution2.save!

      q.license = 'Attribution-NoDerivs'

      i3 # not this one either
      expect(q.all.map(&:id)).to contain_exactly(i2.id)
    end

    specify 'copyright year' do
      attribution1.copyright_year = 1930
      attribution2.copyright_year = 1990
      attribution1.save!
      attribution2.save!

      q.copyright_year = 1990

      i3 # not this one either
      expect(q.all.map(&:id)).to contain_exactly(i2.id)
    end

    specify 'copyright year after' do
      attribution1.copyright_year = 1930
      attribution2.copyright_year = 1990
      attribution3.copyright_year = 1931
      attribution1.save!
      attribution2.save!
      attribution3.save!

      q.copyright_after_year = 1930

      expect(q.all.map(&:id)).to contain_exactly(i2.id, i3.id)
    end

    specify 'copyright year prior to' do
      attribution1.copyright_year = 1930
      attribution2.copyright_year = 1990
      attribution3.copyright_year = 1989
      attribution1.save!
      attribution2.save!
      attribution3.save!

      q.copyright_prior_to_year = 1990

      expect(q.all.map(&:id)).to contain_exactly(i1.id, i3.id)
    end

    specify 'copyright year between' do
      attribution1.copyright_year = 1930
      attribution2.copyright_year = 1990
      attribution3.copyright_year = 1931
      attribution1.save!
      attribution2.save!
      attribution3.save!

      q.copyright_after_year = 1930
      q.copyright_prior_to_year = 1940

      expect(q.all.map(&:id)).to contain_exactly(i3.id)
    end
  end
end
