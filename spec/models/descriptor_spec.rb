require 'rails_helper'

RSpec.describe Descriptor, type: :model, group: :observation_matrix do
  let(:descriptor) { Descriptor.new }

  context 'validation' do
    before { descriptor.valid? }

    specify 'type is required' do
      expect(descriptor.errors.include?(:type)).to be_truthy
    end
   
    specify 'name is required' do
      expect(descriptor.errors.include?(:name)).to be_truthy
    end

    specify 'type of "Descriptor" is not valid' do
      descriptor.type = 'Descriptor'
      descriptor.valid?
      expect(descriptor.errors.include?(:type)).to be_truthy
    end

    specify 'valid types include subclasses' do 
      descriptor.type = 'Descriptor::Qualitative'
      descriptor.valid?
      expect(descriptor.errors.include?(:type)).to be_falsey
    end

    specify 'short_name is at least shorter than name if both provided' do
      descriptor.short_name = 'abcd'
      descriptor.name = 'abc'
      descriptor.valid?
      expect(descriptor.errors.include?(:short_name)).to be_truthy
    end

    context 'soft validation' do
      specify 'short means < 12 characters' do
        descriptor.short_name = '1234567890123'
        descriptor.soft_validate
        expect(descriptor.soft_valid?).to be_falsey
        expect(descriptor.soft_validations.messages_on(:short_name).size).to eq(1)
      end

    end

  end

  context '.sort' do
    let!(:d1) { FactoryBot.create(:valid_descriptor, name: 'd1') }
    let!(:d2) { FactoryBot.create(:valid_descriptor, name: 'd2') }
    let!(:d3) { FactoryBot.create(:valid_descriptor, name: 'd3') }
    let!(:d4) { FactoryBot.create(:valid_descriptor, name: 'd4') }

    let(:project_id) { d1.project_id }

    def ordered_ids
      Descriptor.where(project_id:).order(:position).pluck(:id)
    end

    specify 'reorders the full list' do
      Descriptor.sort([d4.id, d3.id, d2.id, d1.id], project_id)
      expect(ordered_ids).to eq([d4.id, d3.id, d2.id, d1.id])
    end

    specify 'reorders a subset within its own positions' do
      Descriptor.sort([d4.id, d2.id], project_id)
      expect(ordered_ids).to eq([d1.id, d4.id, d3.id, d2.id])
    end

    specify 'does not move descriptors outside the subset' do
      Descriptor.sort([d4.id, d2.id], project_id)
      expect(d1.reload.position).to eq(1)
      expect(d3.reload.position).to eq(3)
    end

    specify 'normalizes nil and duplicate positions' do
      Descriptor.where(id: d1.id).update_all(position: nil)
      Descriptor.where(id: d3.id).update_all(position: d2.position)

      Descriptor.sort([d3.id, d1.id], project_id)

      expect(Descriptor.where(project_id:).order(:position).pluck(:position)).to eq([1, 2, 3, 4])
      expect(ordered_ids).to eq([d2.id, d3.id, d4.id, d1.id])
    end

    specify 'ignores descriptors from other projects' do
      other = FactoryBot.create(:valid_descriptor, project: FactoryBot.create(:valid_project))
      position = other.position

      Descriptor.sort([other.id, d2.id, d1.id], project_id)

      expect(other.reload.position).to eq(position)
      expect(ordered_ids).to eq([d2.id, d1.id, d3.id, d4.id])
    end
  end

end
