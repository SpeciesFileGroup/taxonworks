require 'rails_helper'

RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :matrix, :dna] do
  let(:descriptor) { Descriptor::Gene.new(name: '28s') }
  let(:sequence1) { Sequence.create!(sequence: 'ACT', sequence_type: 'DNA') }
  let(:sequence2) { Sequence.create!(sequence: 'GGG', sequence_type: 'DNA') }
  let(:attribute1) { GeneAttribute.new(descriptor: descriptor, sequence: sequence1, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
  let(:attribute2) { GeneAttribute.new(descriptor: descriptor, sequence: sequence2, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

  let(:forward_primer) { FactoryGirl.create(:valid_sequence) }
  let(:reverse_primer) { FactoryGirl.create(:valid_sequence) }


  context 'validation' do
    context 'sequence / relationship_type combination must be unique' do
      before {
        descriptor.save!
        attribute1.save!
      }

      context 'when duplicated for both sequence / type' do
        before do
          attribute2.sequence = sequence1
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

  context 'associations' do
    specify '#gene_attributes' do
      expect(descriptor.gene_attributes << GeneAttribute.new).to be_truthy
    end
  end
  
  context '#sequences' do
    let(:specimen) { FactoryGirl.create(:valid_specimen) }
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

    context 'a descriptor with no attributes' do
      specify 'returns no #sequences' do
        expect(descriptor.sequences).to eq([])
      end
    end
 
    context 'a descriptor with attributes' do
      before do
        descriptor.save!
        descriptor.gene_attributes.create!(sequence: forward_primer, sequence_relationship_type: 'SequenceRelationship::ForwardPrimer')
        descriptor.gene_attributes.create!(sequence: reverse_primer, sequence_relationship_type: 'SequenceRelationship::ReversePrimer')
      end 

      specify '#gene_attribute_pairs' do
        expect(descriptor.gene_attribute_pairs).to contain_exactly([forward_primer.id, 'SequenceRelationship::ForwardPrimer'],[reverse_primer.id, 'SequenceRelationship::ReversePrimer'])
      end

      specify '#gene_attribute_sequence_ids' do
        expect(descriptor.gene_attribute_sequence_ids).to contain_exactly(forward_primer.id, reverse_primer.id)
      end

      specify '#gene_attribute_sequence_retlationship_types' do
        expect(descriptor.gene_attribute_sequence_retlationship_types).to contain_exactly('SequenceRelationship::ForwardPrimer','SequenceRelationship::ReversePrimer')
      end

      specify 'returns matching #sequences' do
        expect(descriptor.sequences).to contain_exactly(target_sequence1)
      end
 
    end

  end 
end
