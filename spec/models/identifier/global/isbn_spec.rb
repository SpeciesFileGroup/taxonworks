require 'rails_helper'

describe Identifier::Global::Isbn, type: :model, group: :identifiers do
  context 'ISBN' do
    let(:id) { Identifier::Global::Isbn.new(identifier_object: FactoryBot.build(:valid_source)) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify 'any old word' do
        phrase = Faker::Lorem.unique.word
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ISBN.")
      end

      specify 'ISBN-10: 978-0-59652-068-7' do
        phrase = 'ISBN-10: 978-0-59652-068-7'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' has the wrong number of digits.")
      end

      specify 'ISBN-10: 978-0-596-52068-7' do
        phrase = 'ISBN-10: 978-0-596-52068-7'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' has the wrong number of digits.")
      end

      specify 'ISBN-13: 0-596-52068-7' do
        phrase = 'ISBN-13: 0-596-52068-7'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' has the wrong number of digits.")
      end

      specify '69780596520687' do
        phrase = '69780596520687'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' has the wrong number of digits.")
      end

      # ISBN 978-0-596-52068-7
      #
      # ISBN-13: 978-0-596-52068-7
      #
      # 978 0 596 52068 7
      #
      # 9780596520687
      #
      # ISBN-10 0-596-52068-9
      #
      # 0-596-52068-9

      specify 'isbn 978-0-596-52068-7' do
        phrase = 'isbn 978-0-596-52068-7'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      specify 'ISBN-13: 978-0-596-52068-7' do
        id.identifier = 'ISBN-13: 978-0-596-52068-7'
        expect(id.valid?).to be_truthy
      end

      specify '978 0 596 52068 7' do
        id.identifier = '978 0 596 52068 7'
        expect(id.valid?).to be_truthy
      end

      specify '9780596520687' do
        id.identifier = '9780596520687'
        expect(id.valid?).to be_truthy
      end

      specify 'ISBN-10 0-596-52068-9' do
        id.identifier = 'ISBN-10 0-596-52068-9'
        expect(id.valid?).to be_truthy
      end

      specify '0-596-52068-9' do
        id.identifier = '0-596-52068-9'
        expect(id.valid?).to be_truthy
      end

      specify '99942-05-96-X' do
        id.identifier = '99942-05-96-X'
        expect(id.valid?).to be_truthy
      end

      specify '99942-05-97-8' do
        id.identifier = '99942-05-97-8'
        expect(id.valid?).to be_truthy
      end

      specify 'Computational complexity by Christos H. Papadimitriou' do
        id.identifier = '0-2015-3082-1'
        expect(id.valid?).to be_truthy
      end

      # ISBN-10 with 6-digit registrant element (valid per ISBN spec; up to 7 digits allowed).
      # Regression for https://github.com/SpeciesFileGroup/taxonworks/issues/4819.
      specify '2-903052-10-7' do
        id.identifier = '2-903052-10-7'
        expect(id.valid?).to be_truthy
      end

      # ISBN-10 with 7-digit registrant element (upper boundary of the spec)
      specify '0-1234567-8-9' do
        id.identifier = '0-1234567-8-9'
        expect(id.valid?).to be_truthy
      end

      # ISBN-13 with 7-digit registrant element
      specify '978-0-1234567-8-6' do
        id.identifier = '978-0-1234567-8-6'
        expect(id.valid?).to be_truthy
      end

      # 8-digit registrant element exceeds the 7-digit spec maximum
      specify '0-12345678-1-2 has 8-digit registrant element' do
        id.identifier = '0-12345678-1-2'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'0-12345678-1-2' is an improperly formed ISBN.")
      end

      # 8-digit publication element exceeds the 7-digit spec maximum
      specify '0-1-12345678-2 has 8-digit publication element' do
        id.identifier = '0-1-12345678-2'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'0-1-12345678-2' is an improperly formed ISBN.")
      end

      # Bad check digit on an ISBN with a long registrant element
      specify '2-903052-10-8 has bad check digit' do
        id.identifier = '2-903052-10-8'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'2-903052-10-8' has bad check digit.")
      end
    end
  end
end
