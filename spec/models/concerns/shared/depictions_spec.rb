require 'rails_helper'

describe 'Depictions', type: :model do
  let(:instance_with_depiction) { TestDepictionable.new }

  let(:image_attributes) { 
    { image_file: fixture_file_upload(Rails.root + 'spec/files/images/tiny.png', 'image/png') }
   }

  context 'associations' do
    specify 'has many depictions/#has_depictions?' do
      # test that the method notations exists
      expect(instance_with_depiction).to respond_to(:depictions)
      expect(instance_with_depiction.depictions.size == 0).to be_truthy
      # currently has no depictions
    end
  end

  context 'methods' do
    specify '#has_depictions? (none)' do
      expect(instance_with_depiction).to respond_to(:has_depictions?)
      expect(instance_with_depiction.has_depictions?).to be_falsey
    end
    specify '#has_depictions? (1)' do
      expect(instance_with_depiction.depictions << Depiction.new).to be_truthy
      expect(instance_with_depiction.has_depictions?).to be_truthy
      expect(instance_with_depiction.depictions.size == 1).to be_truthy
    end
  end

  context 'object with depictions' do
    context 'on destroy' do
      specify 'attached depictions are destroyed' do
        expect(Depiction.count).to eq(0)
        instance_with_depiction.depictions << FactoryGirl.build(:valid_depiction)
        instance_with_depiction.save
        expect(Depiction.count).to eq(1)
        expect(instance_with_depiction.destroy).to be_truthy
        expect(Depiction.count).to eq(0)
      end
    end
  end

  context 'create with nested depiction' do
    specify 'works by nesting image_attributes' do
      expect(TestDepictionable.create!(
        depictions_attributes: [ {image_attributes:  image_attributes  }  ]
      )).to be_truthy
      expect(Image.count).to eq(1)
      expect(Depiction.count).to eq(1)
    end

    specify 'works with images_attributes' do
      expect(TestDepictionable.create!(images_attributes: [image_attributes])).to be_truthy
      expect(Image.count).to eq(1)
      expect(Depiction.count).to eq(1)
    end
  end


end

class TestDepictionable < ActiveRecord::Base
  include FakeTable
  include Shared::Depictions
end
