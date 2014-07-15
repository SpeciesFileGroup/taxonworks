require 'spec_helper'
require 'material'

describe 'Material' do 
  context '#create_quick_verbatim' do
  
    before(:each) {
      @one_object_stub = {'collection_objects' => {}}
      @one_object_stub['collection_objects']['object1'] = {'total' => nil}
      @one_object_stub['identifier'] = {}

      @two_objects_stub = {'collection_objects' => {}} 
      @two_objects_stub['collection_objects']['object1'] = {'total' => nil}
      @two_objects_stub['collection_objects']['object2'] = {'total' => nil}
   
      @two_objects_stub['identifier'] = {}

      @attribute1 = FactoryGirl.create(:valid_biocuration_class, name: 'adult', definition: 'Big and scary.' )
      @attribute2 = FactoryGirl.create(:valid_biocuration_class, name: 'larva', definition: 'Wormy')
      @attribute3 = FactoryGirl.create(:valid_biocuration_class, name: 'uncategorized', definition: 'Can not figure it out.')
      @attribute4 = FactoryGirl.create(:valid_biocuration_class, name: 'male', definition: 'Not female.')

      @namespace = FactoryGirl.create(:valid_namespace)
      
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

    specify 'returns no collection objects when totals are not set' do
      expect(Material.create_quick_verbatim(@two_objects_stub).collection_objects.count).to eq(0)
    end

    specify 'returns an array of objects when totals are set' do
      @two_objects_stub['collection_objects']['object1']['total'] = 2
      @two_objects_stub['collection_objects']['object2']['total'] = 3

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
      opts = @one_object_stub.merge('repository' => {'id' => repository.id}) 
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

    specify 'identifier is assigned to a single object if a single object is created' do
      @one_object_stub['collection_objects']['object1']['total'] = 1
      @one_object_stub['identifier']['namespace_id'] = @namespace.id
      @one_object_stub['identifier']['identifier'] = '1234'

      r = Material.create_quick_verbatim(@one_object_stub)

      expect(r.collection_objects.first.identifiers.size).to eq(1) # ! .count, it hasn't been saved
    end

    specify 'identifier is assigned to a container if multiple objects are created' do
      @two_objects_stub['collection_objects']['object1']['total'] = 1
      @two_objects_stub['collection_objects']['object2']['total'] = 2

      @two_objects_stub['identifier']['namespace_id'] = @namespace.id
      @two_objects_stub['identifier']['identifier'] = '1234'

      r = Material.create_quick_verbatim(@two_objects_stub)
      expect(r.collection_objects.first.container.identifiers.size).to eq(1) # ! .count
    end

  end
end

describe Material::QuickVerbatimResponse do
  before(:each) {
    @response = Material::QuickVerbatimResponse.new()
  }

  specify '#collection_object' do
    expect(@response.collection_object.class).to eq(Material::QuickVerbatimObject)
  end

  specify  '#locks_object' do
    expect(@response.locks_object.class).to eq(Material::QuickVerbatimLocks)
  end

  context 'data entry locks' do
    specify '#form_params' do
      expect(@response).to respond_to(:form_params)
    end

    specify '#locked?' do
      expect(@response.locked?('note')).to be(false)
    end
  end

  specify '#next_identifier' do
    expect(@response).to respond_to(:next_identifier)
  end

  specify '#next_identifier is nill unless #lock_increment' do
    expect(@response.next_identifier).to eq(nil)
  end

  context '#duplicate_with_locks' do
    before {
      @namespace = FactoryGirl.create(:valid_namespace)
      @repository = FactoryGirl.create(:valid_repository, name: 'The vault.')

      form_params = {
        'note' => {'text' => 'Locked me.'},
        'identifier' => {'namespace_id' => @namespace.id, 'identifier' => '123'},
        'repository' => {'id' => @repository.id}, 
        'locks' => {
          'namespace' => '0',
          'increment' => '1',
          'repository' => '0',
          'collecting_event' => '0',
          'determinations' => '0',
          'other_labels' => '0',
          'note' => '1'          
        }
      }

      @response.form_params = form_params
      @response.build_models

      @new = @response.duplicate_with_locks
    }

    specify 'persists lock_ attributes' do
      expect(@new.locked?('note')).to be(true)
      expect(@new.locked?('increment')).to be(true)
      expect(@new.locked?('namespace')).to be(false)
      expect(@new.locked?('repository')).to be(false)
      expect(@new.locked?('collecting_event')).to be(false)
      expect(@new.locked?('determinations')).to be(false)
      expect(@new.locked?('other_labels')).to be(false)
    end

    context 'persists related objects -' do
      specify 'note' do
        expect(@new.note.text).to eq('Locked me.')  
      end

      specify 'identifier' do
        expect(@new.identifier.namespace).to eq(@namespace)  
      end
    end

    specify 'clears other attributes' do
      expect(@new.repository.name).to be(nil)
    end

    specify 'increments identifier' do
      expect(@new.identifier.identifier).to eq('124')
    end
  end 

  context 'identifier increments' do
    context 'when #lock_increment true' do
      before {
        @response.quick_verbatim_locks.increment = '1' # coming off form_params()
      }
      specify '#next_identifier is +1 when #lock_increment' do
        @response.identifier = FactoryGirl.build(:valid_identifier, identifier: '1')
        expect(@response.next_identifier).to eq('2')
      end

      specify '#next_identifier is +1 when #lock_increment and pre-fixed alphanumeric' do
        @response.identifier = FactoryGirl.build(:valid_identifier, identifier: 'A1')
        expect(@response.next_identifier).to eq('A2')
      end

      specify '#next_identifier is +1 when #lock_increment and post-fixed alphanumeric' do
        @response.identifier = FactoryGirl.build(:valid_identifier, identifier: '1A')
        expect(@response.next_identifier).to eq('2A')
      end

      specify '#next_identifier is +1 when #lock_increment and pre and post-fixed alphanumeric' do
        @response.identifier = FactoryGirl.build(:valid_identifier, identifier: 'AB1A')
        expect(@response.next_identifier).to eq('AB2A')
      end
    end
  end
  
  specify '#collection_objects' do
    expect(@response.collection_objects).to eq([]) 
  end

  # specify '#next_identifier(IdentifierFactory)' do
  #   expect(response.next_identifier.class).to eq(Identifier) 
  # end

  specify '#identifier' do
    expect(@response.identifier.class).to eq(Identifier::Local::CatalogNumber) 
  end

  specify '#repository' do
    expect(@response.repository.class).to eq(Repository) 
  end

  specify '#note' do
    expect(@response.note.class).to eq(Note) 
  end

  specify '#save' do
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

    expect(success).to be(true) 
   
    expect(Specimen.count).to eq(1)
    expect(Identifier.count).to eq(1)
    expect(Note.count).to eq(1)
    expect(BiocurationClassification.count).to eq(1)
  end

end
