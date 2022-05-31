require 'rails_helper'

describe Queries::Extract::Filter, type: :model, group: [:dna, :collection_object] do

  let(:q) { Queries::Extract::Filter.new({}) }

  specify '#origin_facet' do
    e = FactoryBot.create(:valid_extract, origin: Specimen.create! )
    FactoryBot.create(:valid_extract) # not this one
    q.extract_origin = 'CollectionObject'
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#sequences' do
    e = FactoryBot.create(:valid_extract)
    FactoryBot.create(:valid_sequence, origin: e)
    FactoryBot.create(:valid_extract) # not this one
    q.sequences = true
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#extract_start_date_range 1' do
    FactoryBot.create(:valid_extract, year_made: 2000)
    q.extract_start_date_range = '1999-1-1'
    expect(q.all.pluck(:id)).to contain_exactly()
  end

  specify '#extract_start_date_range 2' do
    e = FactoryBot.create(:valid_extract, year_made: 2000)
    q.extract_start_date_range = '2000-01-01'
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#extract_start_date_range 3' do
    e = FactoryBot.create(:valid_extract, year_made: 2000)
    q.extract_start_date_range = '1999-1-1'
    q.extract_end_date_range = '2001-01-1'
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#extract_start_date_range 4' do
    e = FactoryBot.create(:valid_extract, year_made: 2000, month_made: 1, day_made: 1)
    FactoryBot.create(:valid_extract, year_made: 2000, month_made: 1, day_made: 2)

    q.extract_start_date_range = '2000-1-1'
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#extract_start_date_range invalid date is nillified' do
    e = FactoryBot.create(:valid_extract, year_made: 2000)
    q.extract_start_date_range = '2001'
    expect(q.all.pluck(:id)).to contain_exactly(e.id) # nothing matches, so *everything* returned!
  end

  specify '#extract_start_date_range 4' do
    e = FactoryBot.create(:valid_extract, year_made: 2000, month_made: 2, day_made: 1)

    # Not this
    FactoryBot.create(:valid_extract, year_made: 2000, month_made: 2, day_made: 9)

    q.extract_start_date_range = '2000-01-29'
    q.extract_end_date_range = '2000-2-1'
    expect(q.all.pluck(:id)).to contain_exactly(e.id) # nothing matches, so *everything* returned!
  end

  specify '#ancestor_id 1 (otus)' do
    t = FactoryBot.create(:valid_taxon_name)

    o = Otu.create!(taxon_name: t)
    e = FactoryBot.create(:valid_extract, otus: [o])
    FactoryBot.create(:valid_extract)

    q.ancestor_id = t.id
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#ancestor_id 2 (collection_objects)' do
    t = FactoryBot.create(:valid_taxon_name)
    o = Otu.create!(taxon_name: t)
    s = Specimen.create!
    FactoryBot.create(:valid_taxon_determination, otu: o, biological_collection_object: s)
    e = FactoryBot.create(:valid_extract, collection_objects: [s])
    FactoryBot.create(:valid_extract)

    q.ancestor_id = t.id
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#repository_id' do
    r = FactoryBot.create(:valid_repository)
    e = FactoryBot.create(:valid_extract, repository: r)
    FactoryBot.create(:valid_extract) # not this

    q.repository_id = r.id
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#otu_id on Otu' do
    o = Otu.create!(name: 'extractable')
    e = FactoryBot.create(:valid_extract, otus: [o])
    FactoryBot.create(:valid_extract) # not this

    q.otu_id = o.id
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

  specify '#otu_id on Otu and CollectionObject' do
    o = Otu.create!(name: 'extractable')
    d = FactoryBot.create(:valid_taxon_determination, otu: o)
    e = FactoryBot.create(:valid_extract, otus: [o])
    f = FactoryBot.create(:valid_extract, collection_objects: [d.biological_collection_object])
    FactoryBot.create(:valid_extract) # not this

    q.otu_id = o.id
    expect(q.all.pluck(:id)).to contain_exactly(e.id, f.id)
  end

  specify '#collection_object_id' do
    s = Specimen.create
    e = FactoryBot.create(:valid_extract, collection_objects: [s])
    FactoryBot.create(:valid_extract) # not this

    q.collection_object_id = s.id
    expect(q.all.pluck(:id)).to contain_exactly(e.id)
  end

end

