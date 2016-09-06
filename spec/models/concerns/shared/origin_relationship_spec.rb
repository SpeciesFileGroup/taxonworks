require 'rails_helper'

context 'OriginRelationship', :type => :model do
  let(:matching_origin_targets) do
    { origin_relationships_attributes: [{ new_object: TestClass.new }] }
  end

  let(:mismatching_origin_targets) do
    { origin_relationships_attributes: [{ new_object: MismatchingClass.new }] }
  end

  context 'associations' do
    specify 'has many origin_relationships' do
      expect(BaseOriginRelationShip.new.origin_relationships << OriginRelationship.new).to be_truthy
    end
  end

  context 'validations' do
    context 'with "is_origin_for"' do
      context 'matching target origins' do
        specify 'origin_relationship successfully added' do
          origin_object = WithIsOriginForMatching.new(matching_origin_targets)
          origin_object.save!

          expect(origin_object.origin_relationships.length).to be 1
        end
      end

      context 'mismatching target origins' do
        specify 'origin_relationship unsuccessfully added' do
          origin_object = WithIsOriginForMatching.new(mismatching_origin_targets)

          expect(origin_object.valid?).to be_falsey
        end
      end
    end
  end
end

class BaseOriginRelationShip < ActiveRecord::Base
  include Housekeeping
  include FakeTable
  include Shared::OriginRelationship
end

class WithIsOriginForMatching < ActiveRecord::Base
  include Housekeeping
  include FakeTable
  include Shared::OriginRelationship

  is_origin_for :test_classes
end

# This has to be named "TestClass" since the fake table type
# when converted to a symbol is ":test_classes"
class TestClass < ActiveRecord::Base
  include Housekeeping
  include FakeTable
end

class MismatchingClass < ActiveRecord::Base
  include Housekeeping
  include FakeTable
end