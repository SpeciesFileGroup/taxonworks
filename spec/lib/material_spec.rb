require 'spec_helper'
require 'material'

describe 'Material' do 
  context '#create_quick_verbatim' do
  
    before(:each) {
      @one_object_stub = {'collection_objects' => {}}
      @one_object_stub['collection_objects']['object1'] = {'total' => nil}

      @two_objects_stub = {'collection_objects' => {}} 
      @two_objects_stub['collection_objects']['object1'] = {'total' => nil}
      @two_objects_stub['collection_objects']['object2'] = {'total' => nil}
    
      @attribute1 = FactoryGirl.create(:valid_biocuration_class, name: 'adult', definition: 'Big and scary.' )
      @attribute2 = FactoryGirl.create(:valid_biocuration_class, name: 'larva', definition: 'Wormy')
      @attribute3 = FactoryGirl.create(:valid_biocuration_class, name: 'uncategorized', definition: 'Can not figure it out.')
      @attribute4 = FactoryGirl.create(:valid_biocuration_class, name: 'male', definition: 'Not female.')
    }

    specify 'returns a response instance of Material::QuickVerbatimResponse' do
      expect(Material.create_quick_verbatim().class).to eq(Material::QuickVerbatimResponse) 
    end

    specify 'returns no collection objects when no options are passed' do
      expect(Material.create_quick_verbatim.collection_objects).to eq([])
    end

    specify 'returns a single collection object when collection_objects["object1"]["total"] is set' do
      @one_object_stub['collection_objects']['object1']['total'] = 1
      expect(Material.create_quick_verbatim(@one_object_stub).collection_objects.count).to eq(1)
    end

    specify 'returns an array of objects when multiple object totals are set' do
      expect(Material.create_quick_verbatim(@two_objects_stub).collection_objects.count).to eq(2)
    end

    specify 'uses the buffered_ values when provided' do
      event = 'ABCD'
      opts = @one_object_stub.merge('collection_object' => {'buffered_collecting_event' => event}) 
      @one_object_stub['collection_objects']['object1']['total'] = 1
      expect(Material.create_quick_verbatim(opts).collection_objects.count).to eq(1)
      expect(Material.create_quick_verbatim(opts).collection_objects.first.buffered_collecting_event).to eq(event)
    end

    specify 'contains multiple objects with a virtual container when no container provided' do
      @two_objects_stub['collection_objects']['object1']['total'] = 1
      @two_objects_stub['collection_objects']['object2']['total'] = 2
      response = Material.create_quick_verbatim(@two_objects_stub)
      expect(response.collection_objects.first.container.class).to eq(Container::Virtual)
      expect(response.collection_objects.first.container).to eq(response.collection_objects.last.container)
    end

    specify 'assigns a note when provided' do
      text = 'Some text.'
      @one_object_stub['collection_objects']['object1']['total'] = 1
      opts = @one_object_stub.merge(
        'note' => {'text' => text}
      )
      response = Material.create_quick_verbatim(opts)
      expect(response.collection_objects.first.notes.to_a.count).to eq(1)
      expect(response.collection_objects.first.notes.first.text).to eq(text)
    end

    specify 'assigns the "same" note to more than one' do
      text = 'Some text.'
      @two_objects_stub['collection_objects']['object1']['total'] = 1
      @two_objects_stub['collection_objects']['object2']['total'] = 2
    
      opts = @two_objects_stub.merge(
        'note' => {'text' => text}
      )
      r = Material.create_quick_verbatim(opts)
      expect(Material.create_quick_verbatim(opts).collection_objects.count).to eq(2)
      expect(r.collection_objects.first.notes.first.text).to eq(r.collection_objects.last.notes.first.text)
    end

    specify 'material can be assigned to a repository' do
      repository = FactoryGirl.create(:valid_repository)
      @one_object_stub['collection_objects']['object1']['total'] = 1
      opts = @one_object_stub.merge('collection_object' => {'repository_id' => repository.id}) 
      r = Material.create_quick_verbatim(opts)
      expect(r.collection_objects.first.repository).to eq(repository)
    end

    specify 'attributes are assigned' do
      @two_objects_stub['collection_objects']['object1']['total'] = 1
      @two_objects_stub['collection_objects']['object1']['biocuration_classes'] = { @attribute1.to_param => '1',
                                                                                 @attribute2.to_param => '1',
                                                                                 @attribute3.to_param => '1',
                                                                                 @attribute4.to_param => '1'}
      @two_objects_stub['collection_objects']['object2']['total'] = 5
      @two_objects_stub['collection_objects']['object2']['biocuration_classes'] = {@attribute1.to_param => '1',
                                                                                  @attribute4.to_param => '1' }

      r = Material.create_quick_verbatim(@two_objects_stub)

      expect(r.collection_objects.first.biocuration_classes.to_a.count).to eq(4)
      expect(r.collection_objects.last.biocuration_classes.to_a.count).to eq(2)
    
    end

    specify 'records are saved' do
      @two_objects_stub['collection_objects']['object1']['total'] = 1
      @two_objects_stub['collection_objects']['object2']['total'] = 5
      @two_objects_stub['collection_objects']['object2']['biocuration_classes'] = { @attribute1.to_param => '1',
                                                                                 @attribute4.to_param => 1}
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

  specify 'save' do
    a = FactoryGirl.build(:valid_specimen)
    i = FactoryGirl.build(:valid_identifier_local_catalog_number, identified_object: nil)
    n = Note.new(text: "fasdfasdf")
    b = FactoryGirl.build(:valid_biocuration_class) 

    a.identifiers << i 
    a.notes << n
    a.biocuration_classes << b

    @response.collection_objects.push(a)

    expect(Specimen.count).to eq(0)
    expect(Identifier.count).to eq(0)
    expect(Note.count).to eq(0)
    expect(BiocurationClassification.count).to eq(0)

    success, errors = @response.save

    byebug
    expect(success).to be(true) 
   
    expect(Specimen.count).to eq(1)
    expect(Identifier.count).to eq(1)
    expect(Note.count).to eq(1)
    expect(BiocurationClassification.count).to eq(1)
  end

end
