require 'rails_helper'

describe Identifier::Global::OccurrenceId, type: :model, group: :identifiers do

  context 'OccurrenceId' do
    let(:id) {FactoryBot.build(:identifier_global_occurrence_id)}
    let(:id_string) {'http://grbio.org/institution/frost-entomological-museum-penn-state-university/04f7b07d-a62b'}

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify do
        id.identifier = id_string
        expect(id.valid?).to be_truthy
      end

    end
  end
end
