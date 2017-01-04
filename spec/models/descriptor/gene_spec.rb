require 'rails_helper'

RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :matrix] do
  let(:descriptor) { Descriptor::Gene.new(name: '28s') }
  let(:sequence1) { Sequence.create!(sequence: 'ACT', sequence_type: 'DNA') }
  let(:sequence2) { Sequence.create!(sequence: 'GGG', sequence_type: 'DNA') }
  let(:attribute1) { GeneAttribute.new(descriptor: descriptor, sequence: sequence1, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
  let(:attribute2) { GeneAttribute.new(descriptor: descriptor, sequence: sequence2, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

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

    # otu
    # collection object
    # extract
    # sequence1  
    # sequence2
    # sequence3
    # sequence rel1 fwd
    # sequence rel2 rev
    # sequence rel3 fwd
    # sequence rel4 rev
    #
    #

  end 

end
