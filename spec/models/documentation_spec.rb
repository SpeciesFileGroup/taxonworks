require 'rails_helper'

RSpec.describe Documentation, type: :model, group: :documentation do

  let(:documentation) { Documentation.new }
  let(:document) { FactoryBot.create(:valid_document) }

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

end
