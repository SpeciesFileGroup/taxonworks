require 'rails_helper'

describe Export::Packagers::Images, type: :model do
  let(:project) { Project.find(1) }

  specify 'builds grouped preview data for selected images' do
    image_a = FactoryBot.create(:tiny_random_image)
    image_b = FactoryBot.create(:tiny_random_image)

    packager = described_class.new(
      query_params: { image_id: [image_a.id, image_b.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 10.megabytes)

    expect(preview[:total_images]).to eq(2)
    expect(preview[:groups].length).to eq(1)
    expect(preview[:images].map { |i| i[:id] }).to contain_exactly(image_a.id, image_b.id)
  end

  specify 'splits images into multiple groups when size exceeds max' do
    image_a = FactoryBot.create(:tiny_random_image)
    image_b = FactoryBot.create(:tiny_random_image)

    # Set sizes to force grouping
    image_a.update_column(:image_file_file_size, 2.megabytes)
    image_b.update_column(:image_file_file_size, 2.megabytes)

    packager = described_class.new(
      query_params: { image_id: [image_a.id, image_b.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 1.5.megabytes)

    expect(preview[:groups].length).to eq(2)
  end

  specify 'includes image metadata in preview' do
    image = FactoryBot.create(:tiny_random_image)

    packager = described_class.new(
      query_params: { image_id: [image.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 10.megabytes)

    image_data = preview[:images].first
    expect(image_data[:id]).to eq(image.id)
    expect(image_data[:name]).to eq(image.image_file_file_name)
    expect(image_data[:size]).to eq(image.image_file_file_size)
    expect(image_data[:width]).to eq(image.width)
    expect(image_data[:height]).to eq(image.height)
    expect(image_data[:group_index]).to eq(1)
    expect(image_data[:available]).to be(true)
  end

  specify 'returns empty preview when no image_ids provided' do
    packager = described_class.new(
      query_params: { image_id: [] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 10.megabytes)

    expect(preview[:images]).to eq([])
    expect(preview[:groups]).to eq([])
    expect(preview[:total_images]).to eq(0)
  end

  specify '#file_available? returns true when file exists' do
    image = FactoryBot.create(:tiny_random_image)

    packager = described_class.new(
      query_params: { image_id: [image.id] },
      project_id: project.id
    )

    expect(packager.file_available?(image)).to be(true)
  end

  specify '#groups returns grouped images' do
    image_a = FactoryBot.create(:tiny_random_image)
    image_b = FactoryBot.create(:tiny_random_image)

    image_a.update_column(:image_file_file_size, 2.megabytes)
    image_b.update_column(:image_file_file_size, 2.megabytes)

    packager = described_class.new(
      query_params: { image_id: [image_a.id, image_b.id] },
      project_id: project.id
    )

    groups = packager.groups(max_bytes: 1.5.megabytes)

    expect(groups.length).to eq(2)
    expect(groups.flatten.map(&:id)).to contain_exactly(image_a.id, image_b.id)
  end

  context 'with unavailable files' do
    specify 'group size only counts available files' do
      image_a = FactoryBot.create(:tiny_random_image)
      image_b = FactoryBot.create(:tiny_random_image)

      image_a.update_column(:image_file_file_size, 1.megabyte)
      image_b.update_column(:image_file_file_size, 2.megabytes)

      packager = described_class.new(
        query_params: { image_id: [image_a.id, image_b.id] },
        project_id: project.id
      )

      # Make second image unavailable by stubbing file existence
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(image_b.image_file.path).and_return(false)

      preview = packager.preview(max_bytes: 10.megabytes)

      # Both images should be in the group
      expect(preview[:groups].first[:image_ids].length).to eq(2)

      # But size should only count the available image (1 MB)
      expect(preview[:groups].first[:size]).to eq(1.megabyte)

      # available_count should be 1
      expect(preview[:groups].first[:available_count]).to eq(1)
    end

    specify 'marks images as unavailable in serialized data' do
      image = FactoryBot.create(:tiny_random_image)

      packager = described_class.new(
        query_params: { image_id: [image.id] },
        project_id: project.id
      )

      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(image.image_file.path).and_return(false)

      preview = packager.preview(max_bytes: 10.megabytes)

      image_data = preview[:images].first
      expect(image_data[:available]).to be(false)
    end

    specify 'unavailable files do not cause premature group splits' do
      image_a = FactoryBot.create(:tiny_random_image)
      image_b = FactoryBot.create(:tiny_random_image)
      image_c = FactoryBot.create(:tiny_random_image)

      image_a.update_column(:image_file_file_size, 1.megabyte)
      image_b.update_column(:image_file_file_size, 1.megabyte)
      image_c.update_column(:image_file_file_size, 1.megabyte)

      packager = described_class.new(
        query_params: { image_id: [image_a.id, image_b.id, image_c.id] },
        project_id: project.id
      )

      # Make first two images unavailable
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(image_a.image_file.path).and_return(false)
      allow(File).to receive(:exist?).with(image_b.image_file.path).and_return(false)

      # With 1.5 MB limit and 3x 1MB images that count full size, we'd get 2 groups
      # But with unavailable images counting as 0, all 3 should fit in 1 group
      preview = packager.preview(max_bytes: 1.5.megabytes)

      expect(preview[:groups].length).to eq(1)
      expect(preview[:groups].first[:image_ids].length).to eq(3)
      expect(preview[:groups].first[:available_count]).to eq(1)
    end
  end
end
