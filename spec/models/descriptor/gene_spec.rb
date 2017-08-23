require 'rails_helper'

RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :matrix, :dna] do
  let(:descriptor) { Descriptor::Gene.new(name: '28s') }

  let(:sequence1) { Sequence.create!(sequence: 'ACT', sequence_type: 'DNA') }
  let(:sequence2) { Sequence.create!(sequence: 'GGG', sequence_type: 'DNA') }

  let(:forward_primer) { FactoryGirl.create(:valid_sequence) }
  let(:reverse_primer) { FactoryGirl.create(:valid_sequence) }

  let(:attribute1) { GeneAttribute.new(descriptor: descriptor, sequence: forward_primer, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
  let(:attribute2) { GeneAttribute.new(descriptor: descriptor, sequence: reverse_primer, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

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

  context 'associations' do
    specify '#gene_attributes' do
      expect(descriptor.gene_attributes << GeneAttribute.new).to be_truthy
    end
  end

  context 'gene_attribute logic' do
    before { descriptor.save! }

    context 'does not contain attribute' do
      before { attribute1.save! }

      specify 'attributes are automatically appended' do
        expect(descriptor.gene_attribute_logic).to eq(attribute1.to_logic_literal)
      end

      specify 'with AND' do
        attribute2.save!
        expect(descriptor.gene_attribute_logic).to eq(attribute1.to_logic_literal + ' AND ' + attribute2.to_logic_literal)
      end
    end

    context 'user provided' do
      before do
        attribute1.save! 
        attribute2.save!
        descriptor.gene_attribute_logic = "#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}"
        descriptor.save!
      end 

      specify 'logic does not contain duplicate reference to gene attribute' do
        expect(descriptor.gene_attribute_logic).to eq("#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}")
      end
    end
  end

  context 'given some sequences' do
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

      specify 'returns no #or_sequences' do
        expect(descriptor.or_sequences).to eq([])
      end
    end

    context 'a descriptor with attributes' do
      before do
        descriptor.save!
        attribute1.save!
        attribute2.save!
      end 

      specify '#gene_attribute_pairs' do
        expect(descriptor.gene_attribute_pairs).to contain_exactly([forward_primer.id, 'SequenceRelationship::ForwardPrimer'],[reverse_primer.id, 'SequenceRelationship::ReversePrimer'])
      end

      specify '#gene_attribute_sequence_ids' do
        expect(descriptor.gene_attribute_sequence_ids).to contain_exactly(forward_primer.id, reverse_primer.id)
      end

      specify '#gene_attribute_sequence_retlationship_types' do
        expect(descriptor.gene_attribute_sequence_relationship_types).to contain_exactly('SequenceRelationship::ForwardPrimer','SequenceRelationship::ReversePrimer')
      end

      specify 'returns matching #sequences' do
        expect(descriptor.sequences).to contain_exactly(target_sequence1)
      end

      specify 'returns #or_sequences' do
        expect(descriptor.or_sequences).to contain_exactly(target_sequence1, target_sequence2)
      end

      specify 'returns #ge_sequences' do
        expect(descriptor.ga_sequences).to contain_exactly(target_sequence1)
      end

      context 'gene attribute logic' do\
        context '#build_gene_attribute_logic_sql' do
          let(:basic_logic) { 'SequenceRelationship::ForwardPrimer.999' }   

          specify 'returns a useful SQL fragment' do
            expect(descriptor.build_gene_attribute_logic_sql(basic_logic)).to eq(
              %Q{"sequence_relationships"."type" = 'SequenceRelationship::ForwardPrimer' AND "sequence_relationships"."subject_sequence_id" = 999}  
            )
          end

          specify 'moar' do
            l = 'A.1 AND (B.2 OR B.3)'
            byebug
            expect(descriptor.build_gene_attribute_logic_sql(l)).to eq(
              %Q{"sequence_relationships"."type" = 'SequenceRelationship::ForwardPrimer' AND "sequence_relationships"."subject_sequence_id" = 999}  
            )
          end

        end

        context '#gene_attribute_logic' do
          specify 'is rendered as AND when not otherwise provided' do
            expect(descriptor.gene_attribute_logic).to eq("#{attribute1.to_logic_literal} AND #{attribute2.to_logic_literal}")
          end
        end

        context '#cached_gene_attribute_sql' do
          specify 'is rendered as AND when not otherwise provided' do
            expect(descriptor.cached_gene_attribute_sql).to eq(
              %Q{"sequence_relationships"."type" = 'SequenceRelationship::ForwardPrimer' AND "sequence_relationships"."subject_sequence_id" = } +
              attribute1.to_param +
              ' AND ' +
              %Q{"sequence_relationships"."type" = 'SequenceRelationship::ReversePrimer' AND "sequence_relationships"."subject_sequence_id" = } +
              attribute2.to_param
            )
          end

          context 'when #gene_attribute_logic is user updated' do
            before do
              descriptor.gene_attribute_logic = "#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}"
              descriptor.save
            end

            specify 'corresponding cached SQL is as well' do
              expect(descriptor.cached_gene_attribute_sql).to eq(
                %Q{"sequence_relationships"."type" = 'SequenceRelationship::ForwardPrimer' AND "sequence_relationships"."subject_sequence_id" = } +
                attribute1.to_param +
                ' OR ' +
                %Q{"sequence_relationships"."type" = 'SequenceRelationship::ReversePrimer' AND "sequence_relationships"."subject_sequence_id" = } +
                attribute2.to_param
              )
            end 
          end
        end
      end # end gene attribute logic

    end
  end 
end
