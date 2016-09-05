require 'rails_helper'

context 'OriginRelationship', :type => :model do
  let(:class_attributes_single) do
    { origin_relationships_attributes: [{ new_object: FactoryGirl.build(:valid_collection_object) }] }
  end

  let(:with_is_origin_for_blank) do
    WithIsOriginForBlank.new(class_attributes_single) 
  end
  
  let(:without_is_origin_for) do
    WithoutIsOriginFor.new(class_attributes_single) 
  end

  let(:with_is_origin_for_matches) do
    WithIsOriginForMatches.new(class_attributes_single) 
  end
  
  let(:with_is_origin_for_mismatches) do
    WithIsOriginForMismatches.new(class_attributes_single) 
  end

  context 'associations' do
    specify 'has many origin_relationships' do
      expect(BaseOriginRelationShip.new.origin_relationships << OriginRelationship.new).to be_truthy
    end
  end

  context 'validations' do
    context 'with "is_origin_for"' do
      context 'blank, no arguments supplied' do
        specify 'raise "ArgumentError"' do
          expect{with_is_origin_for_blank.save!}.to raise_error(ArgumentError)
        end
      end
    end
    
    context 'without "is_origin_for"' do
      specify 'raise "NoMethodError" for not calling "is_origin_for"' do
        expect{without_is_origin_for.save!}.to raise_error(NoMethodError)
      end
    end
  end
end

class BaseOriginRelationShip < ActiveRecord::Base
  include Housekeeping
  include FakeTable
  include Shared::OriginRelationship
end

class WithIsOriginForBlank < BaseOriginRelationShip
  is_origin_for
end

class WithoutIsOriginFor < BaseOriginRelationShip
end

class WithIsOriginForMatches < BaseOriginRelationShip
  is_origin_for :collection_objects, :extracts
end

class WithIsOriginForMismatches < BaseOriginRelationShip
  is_origin_for :collecting_events
end