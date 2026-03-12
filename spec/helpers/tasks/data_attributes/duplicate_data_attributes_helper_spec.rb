require 'rails_helper'

RSpec.describe Tasks::DataAttributes::DuplicateDataAttributesHelper, type: :helper do
  let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
  let(:project) { FactoryBot.create(:valid_project, creator: user, updater: user) }

  before do
    Current.user_id = user.id
    Current.project_id = project.id
  end

  describe '#duplicate_predicate_data' do
    let(:otu) { FactoryBot.create(:valid_otu, project: project, creator: user, updater: user) }
    let(:predicate) { FactoryBot.create(:valid_predicate, project: project, creator: user, updater: user) }

    # Note: TaxonWorks has a uniqueness validation on InternalAttribute that prevents
    # creating exact duplicates (same predicate + value) through normal means.
    # These duplicates may exist from before the validation was added or via direct SQL.
    # We can only test the case where predicates are duplicated but values differ.

    context 'with 3 data attributes for same predicate, all having different values' do
      let!(:da1) do
        InternalAttribute.create!(
          attribute_subject: otu,
          predicate: predicate,
          value: 'Value 1',
          project: project,
          creator: user,
          updater: user
        )
      end

      let!(:da2) do
        InternalAttribute.create!(
          attribute_subject: otu,
          predicate: predicate,
          value: 'Value 2',
          project: project,
          creator: user,
          updater: user
        )
      end

      let!(:da3) do
        InternalAttribute.create!(
          attribute_subject: otu,
          predicate: predicate,
          value: 'Value 3',
          project: project,
          creator: user,
          updater: user
        )
      end

      it 'returns the object with duplicate predicates' do
        filter = Queries::Otu::Filter.new({ otu_id: otu.id })
        result = helper.duplicate_predicate_data(filter, project.id)

        expect(result[:total_objects_with_duplicates]).to eq(1)
        expect(result[:objects].length).to eq(1)
      end

      it 'returns all 3 data attributes' do
        filter = Queries::Otu::Filter.new({ otu_id: otu.id })
        result = helper.duplicate_predicate_data(filter, project.id)

        data_attributes = result[:objects].first[:data_attributes]
        expect(data_attributes.length).to eq(3)
      end

      it 'marks none as exact duplicates since values differ' do
        filter = Queries::Otu::Filter.new({ otu_id: otu.id })
        result = helper.duplicate_predicate_data(filter, project.id)

        data_attributes = result[:objects].first[:data_attributes]
        expect(data_attributes.none? { |da| da[:is_exact_duplicate] }).to be true
      end
    end

    context 'with no duplicate predicates' do
      let(:predicate2) { FactoryBot.create(:valid_predicate, name: 'Another Predicate', project: project, creator: user, updater: user) }

      let!(:da1) do
        InternalAttribute.create!(
          attribute_subject: otu,
          predicate: predicate,
          value: 'Value 1',
          project: project,
          creator: user,
          updater: user
        )
      end

      let!(:da2) do
        InternalAttribute.create!(
          attribute_subject: otu,
          predicate: predicate2,
          value: 'Value 2',
          project: project,
          creator: user,
          updater: user
        )
      end

      it 'returns no duplicates' do
        filter = Queries::Otu::Filter.new({ otu_id: otu.id })
        result = helper.duplicate_predicate_data(filter, project.id)

        expect(result[:total_objects_with_duplicates]).to eq(0)
        expect(result[:objects]).to be_empty
      end
    end
  end
end
