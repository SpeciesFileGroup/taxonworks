require 'rails_helper'

# See also 
#   descriptor/gene/logic_spec.rb
#   descriptor/gene/sequences_spec.rb
RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :observation_matrix, :dna] do
  let(:descriptor) { Descriptor::Gene.new(name: '28s') }

  let(:sequence1) { Sequence.create!(sequence: 'ACT', sequence_type: 'DNA') }
  let(:sequence2) { Sequence.create!(sequence: 'GGG', sequence_type: 'DNA') }

  let(:forward_primer) { FactoryBot.create(:valid_sequence) }
  let(:reverse_primer) { FactoryBot.create(:valid_sequence) }

  let(:attribute1) { GeneAttribute.new(descriptor: descriptor, sequence: forward_primer, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
  let(:attribute2) { GeneAttribute.new(descriptor: descriptor, sequence: reverse_primer, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

  context 'associations' do
    specify '#gene_attributes' do
      expect(descriptor.gene_attributes << GeneAttribute.new).to be_truthy
    end
  end

  context 'validation' do
    context 'sequence / relationship_type combination must be unique' do
      before do 
        descriptor.save!
        attribute1.save!
      end 

      context 'when duplicated for both sequence / type' do
        before do
          attribute2.sequence = forward_primer 
          attribute2.sequence_relationship_type = SequenceRelationship::ForwardPrimer 
        end 

        specify 'is not valid' do
          expect(attribute2.valid?).to be_falsey
          expect(attribute2.errors.include?(:sequence)).to be_truthy
        end
      end

      context 'when duplicated for type' do
        before {
          attribute2.sequence_relationship_type = SequenceRelationship::ForwardPrimer   
        }
        specify 'is valid' do
          expect(attribute2.valid?).to be_truthy
        end
      end

      context 'when duplicated for sequence' do
        before {
          attribute2.sequence = sequence1
        }
        specify 'is valid' do
          expect(attribute2.valid?).to be_truthy
        end
      end
    end
  end


  context 'given some sequences' do
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let(:extract) { specimen.derived_extracts.create!(quantity_value: 42, quantity_unit: 'kg', year_made: 2012, day_made: 2, month_made: 3) } 
    let!(:target_sequence1) { extract.derived_sequences.create!(
      sequence: 'ACGT', 
      sequence_type: 'DNA',
      forward_primer_relationships_attributes: [{subject_sequence: forward_primer}], 
      reverse_primer_relationships_attributes: [{subject_sequence: reverse_primer} ] 
    )}

    let!(:target_sequence2) { extract.derived_sequences.create!(
      sequence: 'CAT', 
      sequence_type: 'DNA',
      forward_primer_relationships_attributes: [subject_sequence: forward_primer] 
    )}

    let!(:non_target_sequence) { extract.derived_sequences.create!(
      sequence: 'NNT', 
      sequence_type: 'DNA'
    )}

    context 'a descriptor with attributes' do
      before do
        descriptor.save!
        attribute1.save!
        attribute2.save!
      end 

      specify '#gene_attribute_pairs' do
        expect(descriptor.gene_attribute_pairs).to contain_exactly(
          [forward_primer.id, 'SequenceRelationship::ForwardPrimer'],[reverse_primer.id, 'SequenceRelationship::ReversePrimer'])
      end

      specify '.gene_attribute_pairs' do
        expect(Descriptor::Gene.gene_attribute_pairs(descriptor.gene_attributes.all)).to contain_exactly(
          [forward_primer.id, 'SequenceRelationship::ForwardPrimer'],[reverse_primer.id, 'SequenceRelationship::ReversePrimer'])
      end

    end
  end 
end
