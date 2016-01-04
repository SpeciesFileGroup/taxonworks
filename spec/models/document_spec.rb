require 'rails_helper'

RSpec.describe Document, type: :model do

  let(:document) { FactoryGirl.create(:valid_document) }

  after(:each) {
    document.destroy
    document.run_callbacks(:commit)
  }

    # Taken verbatim from the doc. 
  context 'default paperclip tests' do
    it { is_expected.to have_attached_file(:document_file) }
    it { is_expected.to validate_attachment_presence(:document_file) }
    it { is_expected.to validate_attachment_content_type(:document_file).
                  allowing('application/pdf', 'text/plain', 'text/xml').
                  rejecting('image/png') }
    it { is_expected.to validate_attachment_size(:document_file).
                  greater_than(1.byte) }
  end

    
  context 'should manipulate the file system' do
    specify 'creating a document should add it to the filesystem' do
      expect(document.save).to be_truthy
      expect(File.exist?(document.document_file.path)).to be_truthy
    end

    specify 'destroying an image should remove it from the filesystem' do
      path = document.document_file.path
      expect(document.destroy).to be_truthy

      document.run_callbacks(:commit) #       # NOTE: apparently resolved in Paperclip 

      expect(File.exist?(path)).to be_falsey
    end
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
