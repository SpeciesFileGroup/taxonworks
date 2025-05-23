require 'rails_helper'

RSpec.describe ObservationMatrix, type: :model, group: :observation_matrix do
  let(:observation_matrix) { ObservationMatrix.new }
  let(:otu) { Otu.create!(name: 'Matix') }
  let(:descriptor) { Descriptor::Working.create!(name: 'working') }
  let(:collection_object) { Specimen.create! }

  specify '#batch_create otu_query' do
    %w{a ab ac}.collect{|name| Otu.create!(name:)}
    p = ActionController::Parameters.new(
      {observation_matrix: {name: 'Q'},
      otu_query: {name: 'a'}}
      )

    r = ObservationMatrix.batch_create(p)
    expect(r[:observation_matrix_name]).to eq('Q')
    expect(r[:rows]).to eq(3)
  end

  specify '#batch_add otu_query' do
    %w{a ab ac}.collect{|name| Otu.create!(name:)}
    p = ActionController::Parameters.new(
      { project_id:,
        observation_matrix_id: FactoryBot.create(:valid_observation_matrix).id,
        otu_query: {name: 'a'}
      })

    r = ObservationMatrix.batch_add(p)
    expect(r[:rows]).to eq(3)
  end

  specify '#batch_add descriptor' do
    o = %w{1 2 3}.collect{|t| FactoryBot.create(:valid_descriptor)}
    p = ActionController::Parameters.new(
      { project_id:,
        observation_matrix_id: FactoryBot.create(:valid_observation_matrix).id,
        descriptor_query: {descriptor_id: o.map(&:id) }
      })

    r = ObservationMatrix.batch_add(p)
    expect(r[:columns]).to eq(3)
  end

  specify '#batch_add extract' do
    o = %w{1 2 3}.collect{|t| FactoryBot.create(:valid_extract)}
    p = ActionController::Parameters.new(
      { project_id:,
        observation_matrix_id: FactoryBot.create(:valid_observation_matrix).id,
        extract_query: {extract_id: o.map(&:id) }
      })

    r = ObservationMatrix.batch_add(p)
    expect(r[:rows]).to eq(3)
  end

  specify '#batch_add collection_object' do
    o = %w{1 2 3}.collect{|t| FactoryBot.create(:valid_specimen, total: t)}
    p = ActionController::Parameters.new(
      { project_id:,
        observation_matrix_id: FactoryBot.create(:valid_observation_matrix).id,
        collection_object_query: {collection_object_id: o.map(&:id) }
      })

    r = ObservationMatrix.batch_add(p)
    expect(r[:rows]).to eq(3)
  end

  specify '#batch_add observation' do
    sound = FactoryBot.create(:valid_sound)
    fo = FactoryBot.create(:valid_field_occurrence)
    obs1 = Observation::Working.create!(
      descriptor:, observation_object: sound, description: 'mostly static'
    )
    obs2 = Observation::Working.create!(
      descriptor:, observation_object: fo, description: 'mostly branches'
    )

    p = ActionController::Parameters.new(
      { project_id:,
        observation_matrix_id: FactoryBot.create(:valid_observation_matrix).id,
        observation_query: {observation_id: [obs1.id, obs2.id] }
      })

    r = ObservationMatrix.batch_add(p)
    expect(r[:rows]).to eq(2)
    expect(r[:columns]).to eq(1)
  end

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
      observation_matrix.observation_matrix_row_items << ObservationMatrixRowItem::Single.new(observation_object: otu)
      expect(observation_matrix.observation_matrix_rows.count).to eq(1)
    end

    specify 'cascade creates columns from items 1' do
      observation_matrix.observation_matrix_column_items << ObservationMatrixColumnItem::Single::Descriptor.new(descriptor:)
      expect(observation_matrix.observation_matrix_columns.count).to eq(1)
    end

    context 'deletable' do
      specify 'delete matrix' do
        om = ObservationMatrix.create(name: 'test')
        descriptor1 = Descriptor::Continuous.create!(name: 'working')

        r1 = ObservationMatrixRowItem::Single.create!(observation_object: otu, observation_matrix: om)
        r2 = ObservationMatrixRowItem::Single.create!(observation_object: collection_object, observation_matrix: om)
        c3 = ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor:, observation_matrix: om)
        o1 = Observation::Continuous.create!(observation_object: otu, descriptor: descriptor1, continuous_value: 6)
        o2 = Observation::Continuous.create!(observation_object: collection_object, descriptor: descriptor1, continuous_value: 5)
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
