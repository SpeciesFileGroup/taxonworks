require 'rails_helper'
require 'tools/image_matrix'

describe Tools::ImageMatrix, type: :model, group: :observation_matrix do
  context 'image_matrix functionality' do

    let(:observation_matrix) {  ObservationMatrix.create!(name: 'Matrix') }

    let(:genus1) { FactoryBot.create(:relationship_genus, name: 'Aus') }
    let(:species1) { FactoryBot.create(:iczn_species, name: 'aa', parent: genus1) }
    let(:species2) { FactoryBot.create(:iczn_species, name: 'aaa', parent: genus1) }
    let(:species3) { FactoryBot.create(:iczn_species, name: 'aaaa', parent: genus1) }

    let(:otu1) { Otu.create!(taxon_name: species1) }
    let(:otu2) { Otu.create!(taxon_name: species2) }
    let(:otu3) { Otu.create!(taxon_name: species3) }

    let(:descriptor1) { Descriptor::Media.create!(name: 'Descriptor 1') }
    let(:descriptor2) { Descriptor::Media.create!(name: 'Descriptor 2') }
    let(:descriptor3) { Descriptor::Media.create!(name: 'Descriptor 3') }

    let!(:r1) { ObservationMatrixRowItem::Single.create!(observation_object: otu1, observation_matrix: observation_matrix) }
    let!(:r2) { ObservationMatrixRowItem::Single.create!(observation_object: otu2, observation_matrix: observation_matrix) }
    let!(:r3) { ObservationMatrixRowItem::Single.create!(observation_object: otu3, observation_matrix: observation_matrix) }

    let!(:c1) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor1, observation_matrix: observation_matrix) }
    let!(:c2) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor2, observation_matrix: observation_matrix) }
    let!(:c3) { ObservationMatrixColumnItem::Single::Descriptor.create!(descriptor: descriptor3, observation_matrix: observation_matrix) }

    let!(:o1 ) {Observation::Media.create!(descriptor: descriptor1, observation_object: otu1) }
    let!(:o2 ) {Observation::Media.create!(descriptor: descriptor2, observation_object: otu2) }

    let(:image_file) { Rack::Test::UploadedFile.new( Spec::Support::Utilities::Files.generate_png, 'image/png') }
    let(:source) { FactoryBot.create(:valid_source) }
    let!(:depiction1) { Depiction.create!(image_attributes: {image_file: image_file}, depiction_object: o1) }
    let!(:depiction2) { Depiction.create!(image_attributes: {image_file: image_file}, depiction_object: o2) }

    specify '.list_of_descriptors' do
      im = Tools::ImageMatrix.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id)

      expect(im.list_of_descriptors.keys).to contain_exactly(descriptor1.id, descriptor2.id, descriptor3.id)
    end 

    specify 'image_matrix' do
      depiction1.image.citations.create(source: source, is_original: true)
      im = Tools::ImageMatrix.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id)

      expect(im.depiction_matrix.count).to eq(3)

      index =  'Otu' + otu1.id.to_s
      expect(im.depiction_matrix[index][:depictions].count).to eq(3)
      expect(im.depiction_matrix[index][:depictions][0].count).to eq(1)
      expect(im.depiction_matrix[index][:depictions][0].first.source_id).to eq(source.id)
    end

    specify 'image_matrix: otu_filter' do
      im =  Tools::ImageMatrix.new(
        observation_matrix_id: observation_matrix.id,
        project_id: observation_matrix.project_id,
        otu_filter: otu1.id.to_s + '|' + otu2.id.to_s)
      expect(im.list_of_descriptors.count).to eq(3)
      expect(im.depiction_matrix.count).to eq(2)
    end

    specify 'image_matrix: otu_filter, no matrix id 1' do
      im =  Tools::ImageMatrix.new(
        project_id: observation_matrix.project_id,
        otu_filter: otu2.id.to_s + '|' + otu3.id.to_s)
      expect(im.list_of_descriptors.count).to eq(1)
      expect(im.depiction_matrix.count).to eq(1)
    end

    specify 'image_matrix: otu_filter, no matrix id 2' do
      im =  Tools::ImageMatrix.new(
        project_id: observation_matrix.project_id,
        otu_filter: otu1.id.to_s + '|' + otu2.id.to_s + '|' + otu3.id.to_s)
      expect(im.list_of_descriptors.count).to eq(2)
      expect(im.depiction_matrix.count).to eq(2)
    end

  end
end
