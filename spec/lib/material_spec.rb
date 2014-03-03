require 'spec_helper'
require 'material'

describe 'Material' do 
  context '#create_quick_verbatim' do
  
    before(:each) {
      @collection_objects_stub = {collection_objects: {}}
      @collection_objects_stub[:collection_objects][:object1] = {total: nil}
    }

    specify 'returns a response instance of Material::QuickVerbatimResponse' do
      expect(Material.create_quick_verbatim().class).to eq(Material::QuickVerbatimResponse) 
    end

    specify 'returns no collection objects when no options are passed' do
      expect(Material.create_quick_verbatim.collection_objects).to eq([])
    end

    specify 'returns a single collection object when collection_objects[:object1][:total] is set' do
      @collection_objects_stub[:collection_objects][:object1][:total] = 1
      expect(Material.create_quick_verbatim(@collection_objects_stub).collection_objects).to have(1).things
    end

    specify 'returns an array of objects when multiple object totals are set' do
      @collection_objects_stub[:collection_objects][:object1][:total] = 1
      @collection_objects_stub[:collection_objects][:object2] = {} 
      @collection_objects_stub[:collection_objects][:object1][:total] = 2
      expect(Material.create_quick_verbatim(@collection_objects_stub).collection_objects).to have(2).things
    end

    specify 'uses the buffered_ values when provided' do
      event = 'ABCD'
      @params = @collection_objects_stub.merge(collection_object: {buffered_collecting_event: event}) 
      @collection_objects_stub[:collection_objects][:object1][:total] = 1
      expect(Material.create_quick_verbatim(@params).collection_objects).to have(1).things
      expect(Material.create_quick_verbatim(@params).collection_objects.first.buffered_collecting_event).to eq(event)
    end

    specify 'contains multiple objects with a virtual container when no container provided' do
      @collection_objects_stub[:collection_objects][:object1][:total] = 1
      @collection_objects_stub[:collection_objects][:object2] = {} 
      @collection_objects_stub[:collection_objects][:object1][:total] = 2
      response = Material.create_quick_verbatim(@collection_objects_stub)
      expect(response.collection_objects.first.container.class).to eq(Container)
      expect(response.collection_objects.first.container).to eq(response.collection_objects.last.container)
    end

  end
end


describe Material::QuickVerbatimResponse do

  before(:each) {
    @response = Material::QuickVerbatimResponse.new()
  }

  specify '#collection_objects' do
    expect(@response.collection_objects).to eq([]) 
  end

  # specify '#next_identifier(IdentifierFactory)' do
  #   expect(response.next_identifier.class).to eq(Identifier) 
  # end

  specify '#identifier' do
    expect(@response.identifier.class).to eq(Identifier) 
  end

  specify '#repository' do
    expect(@response.repository.class).to eq(Repository) 
  end

  specify '#note' do
    expect(@response.note.class).to eq(Note) 
  end

end
