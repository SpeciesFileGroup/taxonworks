require 'rails_helper'

RSpec.describe Sequence, type: :model, group: [:dna] do
  let(:sequence) {Sequence.new}
  let(:primer) { FactoryGirl.create(:valid_sequence) }
  let(:primer2) { FactoryGirl.create(:valid_sequence) }

  context 'attributes' do
    specify '#name' do
      expect(sequence).to respond_to(:name)
    end

    context '#describe_with' do
      let!(:descriptor) { 
        Descriptor::Gene.create(
          name: 'DESC_WITH', 
          gene_attributes_attributes: [
            { sequence: primer, 
              sequence_relationship_type: 'SequenceRelationship::ForwardPrimer'},
              { sequence: primer2, 
                sequence_relationship_type: 'SequenceRelationship::ReversePrimer'},
          ] ) }

      before do 
        sequence.describe_with = descriptor
        sequence.sequence = 'ACT'
        sequence.sequence_type = :dna
        sequence.save!
      end

      specify 'sequence_relationships are created' do
        expect(sequence.related_sequence_relationships(true).count).to eq(2)
      end
    end
  end

  context 'validation' do
    specify '.valid_new_object_classes' do
      expect(Sequence.valid_new_object_classes).to contain_exactly('Sequence')
    end

    context 'fails when not given' do
      specify 'sequence' do
        sequence.valid?
        expect(sequence.errors.include?(:sequence)).to be_truthy
      end

      specify 'sequence_type' do
        sequence.valid?
        expect(sequence.errors.include?(:sequence_type)).to be_truthy
      end

      specify 'valid sequence_type' do
        sequence = FactoryGirl.create(:valid_sequence)
        sequence.sequence_type = "INVALID TYPE"
        expect(sequence.valid?).to be_falsey
      end
    end

    context 'passes when given' do
      specify 'sequence and valid sequence_type' do
        sequence = FactoryGirl.create(:valid_sequence)
        expect(sequence.valid?).to be_truthy
      end
    end

    context 'associations' do
      context 'has_many helpers' do 
        SequenceRelationship.descendants.each do |d|
          t = d.name.demodulize.tableize.singularize
          relationships = "#{t}_relationships".to_sym
          sequences = "#{t}_sequences".to_sym

          specify "##{relationships}" do
            expect(sequence.send("#{relationships}=", [d.new])).to be_truthy
          end

          specify "##{sequences}" do
            expect(sequence.send("#{sequences}=", [Sequence.new])).to be_truthy
          end

          specify "nested_attributes" do
            expect(sequence.send("#{sequences}_attributes=", [{sequence: Sequence.new}])).to be_truthy
          end
        end

        context 'basic use' do
          before { sequence.update_attributes(sequence_type: 'DNA', sequence: 'ACGT') }
          context 'setting attributes' do
            before do
              sequence.forward_primer_sequences = [ primer ]
              sequence.save!
            end 

            specify 'relationships are created' do
              expect(sequence.related_sequence_relationships.count).to eq(1)
            end

            specify 'reference named relationship' do
              expect(sequence.forward_primer_sequences).to contain_exactly(primer)
            end

            specify 'reference #sequence' do
              expect(primer.sequences).to contain_exactly(sequence)
            end

            specify 'reference #related_sequences' do
              expect(sequence.related_sequences).to contain_exactly(primer)
            end
          end

          context 'nested attributes' do
            before do
              sequence.forward_primer_sequences_attributes = [{sequence: 'ACgT', sequence_type: 'DNA'}] 
              sequence.save!
            end

            specify 'reference #related_sequences' do
              expect(sequence.related_sequences.first.sequence).to eq('ACgT') 
            end
          end
        end
      end
    end
  end
end
