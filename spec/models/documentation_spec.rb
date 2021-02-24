require 'rails_helper'

RSpec.describe Documentation, type: :model, group: :documentation do

  let(:documentation) { Documentation.new }
  let(:document) { FactoryBot.create(:valid_document) }
  let(:otu) { Otu.create!(name: 'dococtou') }

  context 'validation' do
    before { documentation.valid? } 

    specify 'requires #document' do
      expect(documentation.errors.include?(:document)).to be_truthy
    end

    context 'on save'  do
      before do
        # make the documentation otherwise valid
        documentation.document = document
      end

      specify 'invalid documentation_object params are caught by #around_save' do
        expect(documentation.save).to be_falsey
        expect(documentation.errors.include?(:base)).to be_truthy
      end
    end
  end

  specify 'destroys document when last documentation 1' do
    documentation.update!(document: document, documentation_object: otu)
    expect(documentation.destroy).to be_truthy
    expect(Document.count).to eq(0)
  end

  specify 'does not destroy document when additional documentation' do
    documentation.update!(document: document, documentation_object: otu)
    Documentation.create!document: document, documentation_object: Otu.create!(name: 'spiderotu')

    expect(documentation.destroy).to be_truthy
    expect(Document.count).to eq(1)
  end

end
