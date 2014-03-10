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

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    #it_behaves_like 'alternate_values'
    #it_behaves_like 'data_attributes'
    it_behaves_like 'taggable'
  end

end
