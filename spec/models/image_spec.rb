require 'spec_helper'

describe Image do

  context 'has an image'  do
    it { should have_attached_file(:image_file) }
    it { should validate_attachment_presence(:image_file) }
    it { should validate_attachment_content_type(:image_file).
                  allowing('image/png', 'image/gif').
                  rejecting('text/plain', 'text/xml') }
    it { should validate_attachment_size(:image_file).
                  greater_than(1.kilobytes) }

  end

end
