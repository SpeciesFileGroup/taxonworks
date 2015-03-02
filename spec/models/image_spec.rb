require 'rails_helper'

describe Image, :type => :model do
  # Taken verbatim from the doc. 
  context 'default paperclip tests' do
    it { is_expected.to have_attached_file(:image_file) }
    it { is_expected.to validate_attachment_presence(:image_file) }
    it { is_expected.to validate_attachment_content_type(:image_file).
                  allowing('image/png', 'image/gif').
                  rejecting('text/plain', 'text/xml') }
    it { is_expected.to validate_attachment_size(:image_file).
                  greater_than(1.kilobytes) }
  end

  before(:each) do
    @i=FactoryGirl.build(:valid_image)
  end

  # paperclip MD5 add-on tests
  specify 'should have a computed MD5 checksum' do
    expect(@i.image_file_fingerprint.blank?).to be_falsey
    expect(@i.image_file_fingerprint).to eq('00ec7e524efd83ab3533c47bcb659bf6')
  end

  specify 'it should soft validate for duplicate images' do
    # step through all existing records first and delete all the duplicate images.
    Image.all.each do |a|
      if a.image_file_fingerprint == @i.image_file_fingerprint
        a.destroy
        # TODO: Update when Paperclip or Rspec gets modified, or transaction integration gets resolved
        # This causes the necessary callback to get fired within an rspec test, clearing the images.
        # Any destroy method will have to use the same.
        a.run_callbacks(:commit)
      end
    end

    @i.soft_validate
    expect(@i.soft_validations.messages.empty?).to be_truthy
    expect(@i.save).to be_truthy

    k = FactoryGirl.build(:valid_image)
    k.soft_validate
    expect(k.soft_validations.messages_on(:image_file_fingerprint).empty?).to be_falsey
    expect(k.soft_validations.messages).to \
      include 'This image is a duplicate of an image already stored.'
    expect(k.has_duplicate?).to be_truthy
    expect(k.duplicate_images.count).to eq(1)
    expect(k.save).to be_truthy

    j = FactoryGirl.build(:valid_image)
    expect(j.has_duplicate?).to be_truthy
    image_array = j.duplicate_images
    expect(image_array.count).to eq(2)
    expect(image_array.sort).to eq([@i, k].sort)

    j.soft_validate
    expect(j.soft_validations.messages).to include 'This image is a duplicate of an image already stored.'
  end

  specify 'TW attributes should be set before save' do
    weird = FactoryGirl.build(:weird_image)
    expect(@i.save).to be_truthy
    expect(weird.save).to be_truthy

    #'valid images have an unmodified user_file_name' do
    expect(@i.user_file_name).to eq('tiny.png')
    expect(weird.user_file_name).to eq('W3$rd fi(le%=name!.png')

    #check height & width
    expect(@i.height).to eq(18)
    expect(@i.width).to eq(18)
    expect(weird.height).to eq(68)
    expect(weird.width).to eq(400)

    #'the image_file_file_name should not contain any special characters'
    expect(@i.image_file_file_name).to eq('tiny.png')
    expect(weird.image_file_file_name).to eq('w3_rd_fi_le__name_.png')
  end
  context 'should manipulate the file system' do
    specify 'creating an image should add it to the filesystem' do
      expect(@i.save).to be_truthy
      expect(File.exist?(@i.image_file.path)).to be_truthy
    end
    specify 'destroying an image should remove it from the filesystem' do
      expect(@i.destroy).to be_truthy

      # TODO: Update when Paperclip or Rspec gets modified, or transaction integration gets resolved
      # This causes the necessary callback to get fired within an rspec test, clearing the images.
      # Any destroy method will have to use the same.
      @i.run_callbacks(:commit)

      expect(File.exist?(@i.image_file.url)).to be_falsey
    end
  end

  specify 'is the missing image gif path set & present' do
    #TODO we'll need to test that this actually works like we think it does.
    # I believe that paperclip just looks for that path as stated in the const.
    expect(File.exists?(Rails.root.to_s + Image::MISSING_IMAGE_PATH)).to be_truthy
  end

  specify 'exif data should be available if it was provided in the image' do
    # return empty hash when no EXIF data present
    # return correct EXIF data on following images:
    #   Samsung phone - Samsung_Phone.jpg
    #   Exif added later - post_processed.jpg
    #   Exif with comments
    #   Exif with edited data

  end

  skip 'return gps data as decimal degrees'

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
