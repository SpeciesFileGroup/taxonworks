require 'rails_helper'

describe Image, type: :model, group: [:images] do

  let(:i) { FactoryBot.build(:valid_image) }

  # TODO: Update when Paperclip or Rspec gets modified, or transaction integration gets resolved
  # This causes the necessary callback to get fired within an rspec test, clearing the images.
  # Any destroy method will have to use the same.
  after(:each) { i.destroy }

  specify '#filename_depicts_object' do
    co = FactoryBot.create(:valid_collection_object)
    id = Identifier::Local::CatalogNumber.create!(
      namespace: FactoryBot.create(:valid_namespace),
      identifier: '123',
      identifier_object: co
    )

    i = Image.create!(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: "#{id.cached}.png",
      ), 'image/png'),
      filename_depicts_object: true
    )

    expect(i.depictions.count).to eq(1)
    expect(co.depictions.count).to eq(1)
  end


  specify '#filename_depicts_object, not found error' do
    co = FactoryBot.create(:valid_collection_object)
    id = Identifier::Local::CatalogNumber.create!(
      namespace: FactoryBot.create(:valid_namespace),
      identifier: '123',
      identifier_object: co
    )

    i = Image.create(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'unmatched.png',
      ), 'image/png'),
      filename_depicts_object: true
    )

    expect(i.errors.key?(:base)).to be_truthy
  end

  specify 'resaving image retains metadata' do
    a = FactoryBot.create(:valid_image)
    b = a.user_file_name
    c = a.width
    d = a.height

    a.save!
    expect(a.user_file_name).to eq(b)
    expect(a.height).to eq(c)
    expect(a.width).to eq(d)
  end

  specify 'replacing image updates metadata' do
    a = FactoryBot.create(
      :valid_image,
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'foo.png',
      ), 'image/png')
    )

    a.update!(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'bar.png',
        x: 18,
        y: 18
      ), 'image/png')
    )

    expect(a.user_file_name).to eq('bar.png')
    expect(a.height).to eq(18)
    expect(a.width).to eq(18)
  end

  specify 'duplicate images are not allowed 1' do
    a = FactoryBot.create(:valid_image)
    expect(Image.new(image_file: a.image_file).valid?).to be_falsey
  end

  specify 'duplicate images add fingerprint error' do
    a = FactoryBot.create(:valid_image)
    i = Image.new(image_file: a.image_file)
    i.valid?
    expect(i.errors.include?(:image_file_fingerprint)).to be_truthy
  end

  specify '#deduplicate_create' do
    a = FactoryBot.create(:valid_image)
    expect(Image.deduplicate_create(image_file: a.image_file)).to eq(a)
  end

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
      expect(image.errors[:image_file]).to contain_exactly('height must be at least 16 pixels', 'width must be at least 16 pixels')
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

    after { k.destroy }

    # TODO: Deprecated, remove when data are clean
    xspecify '#has_duplicate?' do
      expect(i.has_duplicate?).to be_truthy
      expect(k.has_duplicate?).to be_truthy
    end

    # TODO: Deprecated remove when data are clean
    xspecify '#duplicate_images' do
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
    weird.destroy!
  end

  context 'should manipulate the file system' do
    specify 'creating an image should add it to the filesystem' do
      expect(i.save).to be_truthy
      expect(File.exist?(i.image_file.path)).to be_truthy
    end

    specify 'destroying an image should remove it from the filesystem' do
      path = i.tap(&:save!).image_file.path
      i.destroy!
      expect(File.exist?(path)).to be_falsey
    end
  end

  specify 'is the missing image jpg path set & present' do
    # TODO we'll need to test that this actually works like we think it does.
    # I believe that paperclip just looks for that path as stated in the const.
    expect(File.exist?(Rails.root.to_s + Image::MISSING_IMAGE_PATH)).to be_truthy
  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
