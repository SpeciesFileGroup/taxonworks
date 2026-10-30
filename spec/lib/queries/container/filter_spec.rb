require 'rails_helper'

describe Queries::Container::Filter, type: :model, group: :containers do

  let(:query) { Queries::Container::Filter.new({}) }

  let!(:full_box) { Container::Box.create!(name: 'Alpha box', size_x: 2) }
  let!(:partial_box) { Container::Box.create!(name: 'Beta box', size_x: 3) }
  let!(:empty_vial) { Container::Vial.create!(name: 'Small vial') }
  let!(:empty_rack) { Container::VialRack.create!(name: 'Rack', size_x: 2, size_y: 2, size_z: 2) }

  before do
    full_box.add_container_items([Specimen.create!, Specimen.create!])
    partial_box.add_container_items([Specimen.create!, empty_vial])
  end

  specify '#container_id' do
    query.container_id = [full_box.id, empty_vial.id]
    expect(query.all).to contain_exactly(full_box, empty_vial)
  end

  specify '#type (string)' do
    query.type = 'Container::Box'
    expect(query.all).to contain_exactly(full_box, partial_box)
  end

  specify '#type (array)' do
    query.type = ['Container::Vial', 'Container::VialRack']
    expect(query.all).to contain_exactly(empty_vial, empty_rack)
  end

  specify '#name' do
    query.name = 'box'
    expect(query.all).to contain_exactly(full_box, partial_box)
  end

  specify '#name, #name_exact' do
    query.name = 'Alpha box'
    query.name_exact = true
    expect(query.all).to contain_exactly(full_box)
  end

  specify '#name (array), #name_exact' do
    query.name = ['Alpha box', 'Rack']
    query.name_exact = true
    expect(query.all).to contain_exactly(full_box, empty_rack)
  end

  specify '#empty true' do
    query.empty = true
    expect(query.all).to contain_exactly(empty_vial, empty_rack)
  end

  specify '#empty false' do
    query.empty = false
    expect(query.all).to contain_exactly(full_box, partial_box)
  end

  specify '#full true' do
    query.full = true
    expect(query.all).to contain_exactly(full_box)
  end

  specify '#full false' do
    query.full = false
    expect(query.all).to contain_exactly(partial_box, empty_vial, empty_rack)
  end

  specify '#empty only counts direct contents' do
    outer = Container::Room.create!
    outer.add_container_items([full_box])
    query.empty = false
    expect(query.all).to contain_exactly(outer, full_box, partial_box)
  end

  specify '#full uses x * y * z when all sizes are set' do
    cube = Container::Box.create!(size_x: 1, size_y: 1, size_z: 2)
    cube.add_container_items([Specimen.create!])
    query.full = true
    expect(query.all).to contain_exactly(full_box)
    cube.add_container_items([Specimen.create!])
    expect(query.all).to contain_exactly(full_box, cube)
  end

  specify '#full treats a missing axis as 1 when size_x is set' do
    flat = Container::Box.create!(size_x: 2, size_z: 2)
    flat.add_container_items([Specimen.create!, Specimen.create!])
    query.full = true
    expect(query.all).to contain_exactly(full_box)
    flat.add_container_items([Specimen.create!, Specimen.create!])
    expect(query.all).to contain_exactly(full_box, flat)
  end

  specify '#full false includes populated containers without size' do
    empty_vial.add_container_items([Specimen.create!])
    query.full = false
    expect(query.all).to contain_exactly(partial_box, empty_vial, empty_rack)
  end

  specify '#empty false, #full false (populated)' do
    query.empty = false
    query.full = false
    expect(query.all).to contain_exactly(partial_box)
  end

  specify 'empty and full params from strings' do
    q = Queries::Container::Filter.new(empty: 'false', full: 'false')
    expect(q.all).to contain_exactly(partial_box)
  end

  specify '#size_x_min' do
    query.size_x_min = 3
    expect(query.all).to contain_exactly(partial_box)
  end

  specify '#size_x_max' do
    query.size_x_max = 2
    expect(query.all).to contain_exactly(full_box, empty_rack)
  end

  specify '#size_x_min, #size_x_max' do
    query.size_x_min = 2
    query.size_x_max = 2
    expect(query.all).to contain_exactly(full_box, empty_rack)
  end

  specify '#size_x_min > #size_x_max' do
    query.size_x_min = 3
    query.size_x_max = 2
    expect(query.all).to be_empty
  end

  specify '#size_y_min excludes containers without size_y' do
    query.size_y_min = 1
    expect(query.all).to contain_exactly(empty_rack)
  end

  specify '#size_z_max' do
    query.size_z_max = 2
    expect(query.all).to contain_exactly(empty_rack)
  end

  specify 'size params across axes' do
    query.size_x_min = 2
    query.size_y_max = 3
    query.size_z_min = 2
    expect(query.all).to contain_exactly(empty_rack)
  end

  specify 'size params from strings' do
    q = Queries::Container::Filter.new(size_x_min: '3', size_x_max: '3')
    expect(q.all).to contain_exactly(partial_box)
  end

  specify '#contained_object_type CollectionObject' do
    query.contained_object_type = ['CollectionObject']
    expect(query.all).to contain_exactly(full_box, partial_box)
  end

  specify '#contained_object_type Container' do
    query.contained_object_type = ['Container']
    expect(query.all).to contain_exactly(partial_box)
  end

  specify '#contained_object_type Container subclass' do
    query.contained_object_type = ['Container::Vial']
    expect(query.all).to contain_exactly(partial_box)
  end

  specify '#contained_object_type non-matching Container subclass' do
    query.contained_object_type = ['Container::Box']
    expect(query.all).to be_empty
  end

  specify '#contained_object_type mixed' do
    other_box = Container::Box.create!
    other_box.add_container_items([Container::Jar.create!])
    query.contained_object_type = ['Container::Jar', 'Extract']
    expect(query.all).to contain_exactly(other_box)
  end

  context 'identifiers' do
    let(:namespace) { FactoryBot.create(:valid_namespace) }

    before do
      Identifier::Local::CatalogNumber.create!(identifier_object: partial_box, namespace:, identifier: '12')
    end

    specify '#identifier matches own and nested containers' do
      query.identifier = '12'
      expect(query.all).to contain_exactly(partial_box, empty_vial)
    end

    specify '#namespace_id' do
      query.namespace_id = namespace.id
      expect(query.all).to contain_exactly(partial_box, empty_vial)
    end

    specify '#identifiers true' do
      query.identifiers = true
      expect(query.all).to contain_exactly(partial_box, empty_vial)
    end

    specify '#identifiers false' do
      query.identifiers = false
      expect(query.all).to contain_exactly(full_box, empty_rack)
    end

    specify '#identifier_type' do
      query.identifier_type = ['Identifier::Local::CatalogNumber']
      expect(query.all).to contain_exactly(partial_box, empty_vial)
    end

    specify '#local_identifiers true' do
      query.local_identifiers = true
      expect(query.all).to contain_exactly(partial_box, empty_vial)
    end

    specify '#identifier_start, #identifier_end' do
      query.identifier_start = '10'
      query.identifier_end = '15'
      expect(query.all).to contain_exactly(partial_box, empty_vial)
    end

    specify '#match_identifiers' do
      q = Queries::Container::Filter.new(
        match_identifiers: partial_box.identifiers.first.cached,
        match_identifiers_delimiter: ',',
        match_identifiers_type: 'identifier'
      )
      expect(q.all).to include(partial_box)
    end

    specify '#match_identifiers internal' do
      q = Queries::Container::Filter.new(
        match_identifiers: "#{full_box.id},#{empty_rack.id}",
        match_identifiers_delimiter: ',',
        match_identifiers_type: 'internal'
      )
      expect(q.all).to contain_exactly(full_box, empty_rack)
    end
  end

  specify 'combined facets' do
    query.type = 'Container::Box'
    query.full = false
    query.size_x_min = 3
    expect(query.all).to contain_exactly(partial_box)
  end

end
