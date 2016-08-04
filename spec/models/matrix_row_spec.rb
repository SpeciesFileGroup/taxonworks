require 'rails_helper'

RSpec.describe MatrixRow, type: :model, group: :matrix do
  
=begin
  Co = collection_object

  Validation
    Valid matrix row
      When valid matrix
        When only Otu, pass
        When only Co, pass
    Invalid matix row
      When no valid matrix 
      When valid matrix
        When Otu AND Co, fail
        When no Otu AND no Co, fail
=end

  let(:matrix_row) {MatrixRow.new}

  context :validation do
    let(:valid_matrix_given) do
      matrix_row.matrix = FactoryGirl.create(:valid_matrix)
    end

    let(:valid_otu_given) do
      matrix_row.otu = FactoryGirl.create(:valid_otu)
    end

    let(:valid_collection_object_given) do
      matrix_row.collection_object = FactoryGirl.create(:valid_collection_object)
    end

    context 'with valid matrix given' do
      before do
        valid_matrix_given
      end

      context :valid_matrix_row do
        specify 'only Otu given' do
          valid_otu_given
          expect(matrix_row.valid?).to be_truthy
        end

        specify 'only Collection Object given' do
          valid_collection_object_given
          matrix_row.valid?
          expect(matrix_row.valid?).to be_truthy
        end
      end
    end

    context :invalid_matrix_row do
      specify 'no matrix given' do
        matrix_row.valid?
        expect(matrix_row.errors.include?(:matrix)).to be_truthy
      end

      context 'with valid matrix given' do
        before do
          valid_matrix_given
        end

        specify 'Otu AND Collection Object given' do
          valid_otu_given
          valid_collection_object_given
          matrix_row.valid?
          expect(matrix_row.errors.include?(:base)).to be_truthy
        end

        specify 'neither Otu nor Collection Object given' do
          matrix_row.valid?
          expect(matrix_row.errors.include?(:base)).to be_truthy
        end

        specify 'creating 2 MatrixRow with same matrix and same otu' do
          matrix = FactoryGirl.create(:valid_matrix)
          otu = FactoryGirl.create(:valid_otu)

          MatrixRow.create!(matrix_id: matrix.id, otu_id: otu.id)
          expect(MatrixRow.create(matrix_id: matrix.id, otu_id: otu.id).id).to be_falsey
        end

        specify 'creating 2 MatrixRow with same matrix and same collection object' do
          matrix = FactoryGirl.create(:valid_matrix)
          co = FactoryGirl.create(:valid_collection_object)

          MatrixRow.create!(matrix_id: matrix.id, collection_object_id: co.id)
          expect(MatrixRow.create(matrix_id: matrix.id, collection_object_id: co.id).id).to be_falsey
        end
      end
    end
  end
end