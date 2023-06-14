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
    end
  end
end
