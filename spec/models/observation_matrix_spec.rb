require 'rails_helper'

RSpec.describe ObservationMatrix, type: :model, group: :observation_matrix do
  let(:observation_matrix) { ObservationMatrix.new }
  let(:otu) { Otu.create!(name: 'Matix') }
  let(:descriptor) { Descriptor::Working.create!(name: 'working') }
  let(:collection_object) { Specimen.create! }

  context 'associations' do 
    context 'has_many' do
      specify '#observation_matrix_column_items' do
        expect(observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem.new).to be_truthy
      end

      specify '#observation_matrix_row_items' do
        expect(observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem.new).to be_truthy
      end
    end
  end

  context :validation do
    before { observation_matrix.valid? }
    specify '#name is required' do
      expect(observation_matrix.errors.include?(:name)).to be_truthy
    end
  end

  context '<<' do
    before do
      observation_matrix.name = 'Test'
      observation_matrix.save!
    end

    specify 'cascade creates rows from items 1' do
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::Otu.new(otu: otu) 
      expect(observation_matrix.observation_matrix_rows.count).to eq(1)
    end

    specify 'cascade creates rows from items 2' do
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single::CollectionObject.new(collection_object: collection_object) 
      expect(observation_matrix.observation_matrix_rows.count).to eq(1)
    end

    specify 'cascade creates columns from items 1' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor: descriptor)
      expect(observation_matrix.observation_matrix_columns.count).to eq(1)
    end

    context 'deletable' do
      specify 'delete matrix' do
        om = ObservationMatrix.create(name: 'test')
        descriptor1 = Descriptor::Continuous.create!(name: 'working')

        r1 = ObservationMatrixRowItem::Single::Otu.create!(otu: otu, observation_matrix: om)
        r2 = ObservationMatrixRowItem::Single::CollectionObject.create!(collection_object: collection_object, observation_matrix: om)
        c3 = ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor, observation_matrix: om)
        o1 = Observation.create!(otu: otu, descriptor: descriptor1, continuous_value: 6)
        o2 = Observation.create!(collection_object: collection_object, descriptor: descriptor1, continuous_value: 5)
        om.reload

        expect(ObservationMatrix.where(id: om.id).first.nil?).to be_falsey
        expect(ObservationMatrixRowItem.where(id: r1.id).first.nil?).to be_falsey
        expect(ObservationMatrixRowItem.where(id: r2.id).first.nil?).to be_falsey
        expect(ObservationMatrixColumnItem.where(id: c3.id).first.nil?).to be_falsey

        expect(om.destroy!).to be_truthy

        expect(ObservationMatrix.where(id: om.id).first.nil?).to be_truthy
        expect(ObservationMatrixRowItem.where(id: r1.id).first.nil?).to be_truthy
        expect(ObservationMatrixRowItem.where(id: r2.id).first.nil?).to be_truthy
        expect(ObservationMatrixColumnItem.where(id: c3.id).first.nil?).to be_truthy

        expect(Otu.where(id: otu.id).first.nil?).to be_falsey
        expect(CollectionObject.where(id: collection_object.id).first.nil?).to be_falsey
        expect(Descriptor.where(id: descriptor1.id).first.nil?).to be_falsey
        expect(Observation.where(id: o1.id).first.nil?).to be_falsey
        expect(Observation.where(id: o2.id).first.nil?).to be_falsey
      end
    end
  end
end
