require 'rails_helper'

describe Image, type: :model, group: [:images] do

  let(:i) { FactoryBot.build(:valid_image) }

  after(:each) {
    # step through all existing records first and delete all the duplicate images.
#   Image.all.each_with_index do |a, i|
#     if a.image_file_fingerprint == i.image_file_fingerprint
#       a.destroy
#       # TODO: Update when Paperclip or Rspec gets modified, or transaction integration gets resolved
#       # This causes the necessary callback to get fired within an rspec test, clearing the images.
#       # Any destroy method will have to use the same.
#       a.run_callbacks(:commit)
#     end
#   end

    # TODO: Update when Paperclip or Rspec gets modified, or transaction integration gets resolved
    # This causes the necessary callback to get fired within an rspec test, clearing the images.
    # Any destroy method will have to use the same.
    i.destroy
    i.run_callbacks(:commit)
  }

  # Taken verbatim from the doc. 
  context 'default paperclip tests' do
    it { is_expected.to have_attached_file(:image_file) }
    it { is_expected.to validate_attachment_presence(:image_file) }
    it { is_expected.to validate_attachment_content_type(:image_file).
         allowing('image/png', 'image/gif').
         rejecting('text/plain', 'text/xml') }
  end

  context 'dimensions validation' do
    it 'rejects tiny images' do
      image = FactoryBot.build(:very_tiny_image)
      image.save
      expect(image.errors[:image_file]).to contain_exactly("height must be at least 16 pixels", "width must be at least 16 pixels")
    end

    it 'accepts larger images' do
      expect(i).to be_valid
    end
  end

  # paperclip MD5 add-on tests
  specify 'should have a computed MD5 checksum' do
    expect(i.image_file_fingerprint.blank?).to be_falsey
    expect(i.image_file_fingerprint).to eq('00ec7e524efd83ab3533c47bcb659bf6')
  end

  specify 'it has no soft validation warning on duplicate image when image is unique' do
    i.save!
    i.soft_validate
    expect(i.soft_validations.messages_on(:image_file_fingerprint)).to eq([])
  end

  context 'with mulitiple images' do
    let!(:k) {FactoryBot.create(:valid_image)}

    before {
      i.save!
      i.soft_validate
      k.soft_validate
    }

    after {
      k.destroy
      k.run_callbacks(:commit)
    }

    specify 'once saved, it should soft validate for duplicate images already saved to database' do
      expect(i.soft_validations.messages).to include 'This image is a duplicate of an image already stored.'
      expect(k.soft_validations.messages).to include 'This image is a duplicate of an image already stored.'
    end

    specify '#has_duplicate?' do
      expect(i.has_duplicate?).to be_truthy
      expect(k.has_duplicate?).to be_truthy
    end

    specify '#duplicate_images' do
      expect(i.duplicate_images).to eq([k])
    end
  end

  specify 'TW attributes should be set before save' do
    weird = FactoryBot.build(:weird_image)
    expect(i.save).to be_truthy
    expect(weird.save).to be_truthy

    # 'valid images have an unmodified user_file_name' do
    expect(i.user_file_name).to eq('tiny.png')
    expect(weird.user_file_name).to eq('W3$rd fi(le%=name!.png')

    #check height & width
    expect(i.height).to eq(18)
    expect(i.width).to eq(18)
    expect(weird.height).to eq(68)
    expect(weird.width).to eq(400)

    # 'the image_file_file_name should not contain any special characters'
    expect(i.image_file_file_name).to eq('tiny.png')
    expect(weird.image_file_file_name).to eq('w3_rd_fi_le__name_.png')
 
    # Manual paperclip callbacks 
    weird.destroy
    weird.run_callbacks(:commit)
  end
  
  context 'should manipulate the file system' do
    specify 'creating an image should add it to the filesystem' do
      expect(i.save).to be_truthy
      expect(File.exist?(i.image_file.path)).to be_truthy
    end

    specify 'destroying an image should remove it from the filesystem' do
      path = i.image_file.path
      expect(i.destroy).to be_truthy
      #  i.run_callbacks(:commit) #       # NOTE: apparently resolved in Paperclip 
      expect(File.exist?(path)).to be_falsey
    end
  end

  specify 'is the missing image jpg path set & present' do
    # TODO we'll need to test that this actually works like we think it does.
    # I believe that paperclip just looks for that path as stated in the const.
    expect(File.exists?(Rails.root.to_s + Image::MISSING_IMAGE_PATH)).to be_truthy
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
