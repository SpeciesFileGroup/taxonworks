require 'rails_helper'

describe 'Documention', type: :model, group: :documentation do
  let(:instance_with_documentation) { TestDocumentable.new }

  let(:document1) { Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_pdf, 'application/pdf') }
  let(:document2) { Rack::Test::UploadedFile.new(Rails.root + 'spec/files/documents/tiny.txt', 'text/plain') }

  let(:document_attributes) {
    { document_file: document1 }
  }

  context 'associations' do
    specify '#documents' do
      expect(instance_with_documentation).to respond_to(:documents)
    end

    specify '#documentation' do 
      expect(instance_with_documentation).to respond_to(:documentation)
    end
  end

  specify '#documented? (none)' do
    expect(instance_with_documentation.documented?).to be_falsey 
  end

  specify '#documented? (1)' do
    instance_with_documentation.documents << Document.new
    expect(instance_with_documentation.documented?).to be_truthy
  end

  context 'object with documentation' do
    context 'on destroy' do
      specify 'attached documentation is destroyed' do
        expect(Documentation.count).to eq(0)
        instance_with_documentation.documentation << FactoryBot.build(:valid_documentation)
        instance_with_documentation.save
        expect(Documentation.count).to eq(1)
        expect(instance_with_documentation.destroy).to be_truthy
        expect(Documentation.count).to eq(0)
      end
    end
  end

  context 'create with nested documentation' do
    specify 'works by nesting document_attributes' do
      expect(TestDocumentable.create!(
        documentation_attributes: [ {document_attributes: document_attributes} ]
      )).to be_truthy
      expect(Document.count).to eq(1)
      expect(Documentation.count).to eq(1)
    end

    specify 'works with documents_attributes' do
      expect(TestDocumentable.create!(documents_attributes: [document_attributes])).to be_truthy
      expect(Document.count).to eq(1)
      expect(Documentation.count).to eq(1)
    end
  end

  context 'create with #document_array' do
    let(:data) {
      { '0' => document1, '1' => document2 }
    }

    specify '#document_array' do
      expect(instance_with_documentation).to respond_to('document_array=')
    end

    specify 'succeeds' do
      instance_with_documentation.document_array = data
      expect(instance_with_documentation.save).to be_truthy
      expect(instance_with_documentation.documents.count).to eq(2)
      expect(instance_with_documentation.documents.first.id).to be_truthy
    end
  end

end

class TestDocumentable < ApplicationRecord
  include FakeTable
  include Shared::Documentation
end
