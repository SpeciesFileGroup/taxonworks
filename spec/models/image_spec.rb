require 'spec_helper'

describe Image do

  # default recommended tests for paperclip
  # (default associated columns are image_file_file_name, image_file_content_type(mime type?), image_file_file_size,
  # image_file_updated_at)
  it { should have_attached_file(:image_file) }
  it { should validate_attachment_presence(:image_file) }
  it { should validate_attachment_content_type(:image_file).
                allowing('image/png', 'image/gif').
                rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:image_file).
                greater_than(1.kilobytes) }

  # paperclip MD5 add-on tests
  pending 'it should have a computed MD5 checksum on save'

  # TW add on attributes
  pending 'valid images have a user_file_name'
  pending 'it should save height & width on save'
  pending 'user_image_name? '  #todo what is this and how is it different from user_file_name?

  context 'should manipulate the file system' do
    specify 'by saving the image on object save' do
      i=FactoryGirl.build(:valid_image)
      expect(i.save).to be_true
      #check the file system for the file

      #expect(i.update(image_file: nil)).to be_true
      #expect(i.save).to be_true
      foo = 9
      expect(i.destroy).to be_true
      foo = 1
      #check the file system that the file is gone
    end

  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    #it_behaves_like 'alternate_values'
    #it_behaves_like 'data_attributes'
    it_behaves_like 'taggable'
  end

end
