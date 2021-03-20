require 'rails_helper'

context 'OriginRelationship', type: :model do

  specify '.valid_new_object_classes' do
    TestClass.is_origin_for('TestClass')
    expect(TestClass.valid_new_object_classes).to contain_exactly('TestClass') 
  end

  specify '#valid_new_object_classes' do
    TestClass.is_origin_for('TestClass')
    t = TestClass.new 
    expect(t.valid_new_object_classes).to contain_exactly('TestClass') 
  end

  specify '.valid_old_object_classes' do
    TestClass.originates_from('TestClass')
    expect(TestClass.valid_old_object_classes).to eq(['TestClass'])
  end

  specify '#valid_old_object_classes' do
    TestClass.originates_from('TestClass')
    t = TestClass.new
    expect(t.valid_old_object_classes).to eq(['TestClass'])
  end

  context 'associations' do
    specify 'has many origin_relationships' do
      expect(BaseOriginRelationShip.new.origin_relationships << OriginRelationship.new).to be_truthy
    end
  end

  context 'validation' do

    let(:matching_origin_targets) do
      { origin_relationships_attributes: [{ new_object: TestClass.new }] }
    end

    context 'with "is_origin_for" and "originates_from"' do
      context 'and origins aligned/matching' do
        specify 'origin_relationship successfully added' do
          WithIsOriginForMatching.is_origin_for('TestClass')
          TestClass.originates_from('WithIsOriginForMatching')
          origin_object = WithIsOriginForMatching.create!(matching_origin_targets) 
          expect(origin_object.origin_relationships.length).to be 1
        end
      end

      context 'mismatching target origins' do
        specify 'and origins created, but not aligned/matching, fails to save' do
          WithIsOriginForMatching.is_origin_for('WithIsOriginForMatching')
          TestClass.originates_from('WithIsOriginForMatching')

          origin_object = TestClass.create(matching_origin_targets) 
          expect(origin_object.origin_relationships.reload.length).to be 0
        end 
      end

      specify 'raises without one of "is_origin_for" or "originates_from"' do
        origin_object = WithIsOriginForMatching.create( origin_relationships_attributes: [{ new_object: MismatchingClass.new }]  )
        expect(origin_object.new_objects.count).to eq(0)
      end

    end
  end

  context 'new/old objects' do

    before { WithIsOriginForMatching.is_origin_for('TestClass') }
    
    context 'with classes properly configured' do
      let(:o) { WithIsOriginForMatching.create }
      let(:n) { TestClass.create }

      context '#origin' do
        context 'with #origin=' do
          before { n.update!(origin: o) }

          specify 'can create a relationship' do
            expect(n.related_origin_relationships.count).to eq(1)
          end
        end

        context 'with params' do
          let!(:z) { TestClass.create!(origin: o) }

          specify 'can create a relationship' do
            expect(z.related_origin_relationships.count).to eq(1)
            expect(z.old_objects).to contain_exactly(o)
          end 
        end
      end


      specify '#old_objects' do 
        expect(o).to respond_to(:old_objects)
        expect(n).to respond_to(:old_objects)
      end

      specify '#new_objects' do
        expect(o).to respond_to(:new_objects)
        expect(n).to respond_to(:new_objects)
      end

      context 'returning objects' do
        let!(:relationship) { OriginRelationship.create!(old_object: o, new_object: n) }

        specify '#new_objects' do
          expect(o.new_objects).to contain_exactly(n)
        end

        specify '#old_objects' do
          expect(n.old_objects).to contain_exactly(o)
        end
      end
    end

  end
end

class BaseOriginRelationShip < ApplicationRecord
  include Housekeeping
  include FakeTable
  include Shared::OriginRelationship
end

class WithIsOriginForMatching < ApplicationRecord
  include Housekeeping
  include FakeTable
  include Shared::OriginRelationship

  is_origin_for 'TestClass'
end

# This has to be named "TestClass" since the fake table type
# when converted to a symbol is ":test_classes"
class TestClass < ApplicationRecord
  include Housekeeping
  include FakeTable
  include Shared::OriginRelationship
end

class MismatchingClass < ApplicationRecord
  include Housekeeping
  include FakeTable
end
