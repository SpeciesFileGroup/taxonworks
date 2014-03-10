require 'spec_helper'

describe Image do
  # Taken verbatim from the doc. 
  context 'default paperclip tests' do
    it { should have_attached_file(:image_file) }
    it { should validate_attachment_presence(:image_file) }
    it { should validate_attachment_content_type(:image_file).
         allowing('image/png', 'image/gif').
         rejecting('text/plain', 'text/xml') }
    it { should validate_attachment_size(:image_file).
         greater_than(1.kilobytes) }
  end

  # paperclip MD5 add-on tests
  pending 'it should have a computed MD5 checksum on save'

  # TW add on attributes
  pending 'valid images have a user_file_name'
  pending 'it should save height'
  pending 'it should save width' 

  context 'should manipulate the file system' do
    specify 'destroying an image should remove it form the filesystem' do
      i=FactoryGirl.build(:valid_image)
      expect(i.save).to be_true
    
      # setup with likely something like
      # some_file_path = i.url

      # TODO: write this
      # expect(some_file_path.exists?).to be_true

      expect(i.destroy).to be_true
      
      # TODO: Update when Paperclip or Rspec get's modified, or transaction integration gets resolved 
      # This causes the necessary callback to get fired within an rspec test, clearing the images.
      # Any destroy method will have to use the same.
      i.run_callbacks(:commit)

      # TODO: write this
      #check the file system that the file is gone
      # expect(some_file_path.exists?).to be_false
    end
  end

  # TODO: Leave testing out here- needs to be abstracted, and will only add lenght here.
  context 'concerns' do
    # it_behaves_like 'identifiable'
    # it_behaves_like 'notable'
    #  #it_behaves_like 'alternate_values'
    #  #it_behaves_like 'data_attributes'
    # it_behaves_like 'taggable'
  end

end
