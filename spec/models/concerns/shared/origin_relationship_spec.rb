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

  context 'validations' do
    let(:matching_origin_targets) do
      { origin_relationships_attributes: [{ new_object: TestClass.new }] }
    end

    context 'with "is_origin_for"' do
      context 'matching target origins' do

        let(:origin_object) { WithIsOriginForMatching.new(matching_origin_targets) }

        before {
          origin_object.save!
        }

        specify 'origin_relationship successfully added' do
          expect(origin_object.origin_relationships.length).to be 1
        end
      end

      context 'mismatching target origins' do
        let(:o) { OriginRelationship.new( new_object: MismatchingClass.new, old_object: TestClass.new) }

        let(:mismatching_origin_targets) do
          { origin_relationships_attributes: [{ new_object: MismatchingClass.new }] }
        end

        specify 'invalid old/new pairs are invalid' do
          expect(o.valid?).to be_falsey
          expect(o.errors.include?(:new_object)).to be_truthy
        end 

        specify 'origin_relationship rejected on save' do
          origin_object = WithIsOriginForMatching.create(mismatching_origin_targets)
          expect(origin_object.new_objects.count).to eq(0)
        end
      end
    end
  end

  context 'new/old objects' do
    let(:o) { WithIsOriginForMatching.create }
    let(:n) { TestClass.create }


    context '#origin' do
      context 'with #origin=' do
        before do
          n.origin = o
          n.save 
        end

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
