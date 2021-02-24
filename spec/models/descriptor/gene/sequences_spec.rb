require 'rails_helper'

RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :observation_matrix, :dna] do
  
  # The following data is described in this spec:
  #
  # Arbitrary (and anonymous, i.e. it doesn't matter what the ACGT values are, nor that the "primer" sequences are nonsensical values) lengths of DNA.
  #
  # * Indicates a related sequence (primer, blast query, etc.)
  #
  # Sequences
  #       
  #         *------- 1 ------* 
  #                 *--- 2 *-* 
  #                 *-- 3 -*
  #                               *--- 4 ---*    *---- 12 ----   
  #         5       6   7  8 9    10       11    13               14 
  #         |       |   |  | |    |         |    |                 
  #         ------------------    -----------    -------------   -----
  #                                                    
  # Target sequence attributes
  #
  # 1
  # 5 Forward
  # 9 Reverse
  #
  # 2 
  # 6 Forward
  # 8 Reverse
  # 9 Reverse
  #
  # 3
  # 6 Forward
  # 8 Reverse
  #
  # 4
  # 10 Forward
  # 11 Reverse
  #
  # 12
  # 13 Blast
  #
  # 14
  # (undescribed!)
  #
  #
  # 5 letter sequences are targets
  # 4 letter are fwd
  # 3 letter are rev
  # 2 letter are blast 
  let!(:s1)  { Sequence.create!(sequence: 'ACGTG', sequence_type: 'DNA') }
  let!(:s2)  { Sequence.create!(sequence: 'ACTCG', sequence_type: 'DNA') }
  let!(:s3)  { Sequence.create!(sequence: 'ACTTA', sequence_type: 'DNA') }
  let!(:s4)  { Sequence.create!(sequence: 'ACCAA', sequence_type: 'DNA') }
  let!(:s5)  { Sequence.create!(sequence: 'GTT', sequence_type: 'DNA') }
  let!(:s6)  { Sequence.create!(sequence: 'TTT', sequence_type: 'DNA') }
  let!(:s7)  { Sequence.create!(sequence: 'AAA', sequence_type: 'DNA') }
  let!(:s8)  { Sequence.create!(sequence: 'CCC', sequence_type: 'DNA') }
  let!(:s9)  { Sequence.create!(sequence: 'ATA', sequence_type: 'DNA') }
  let!(:s10) { Sequence.create!(sequence: 'AGA', sequence_type: 'DNA') }
  let!(:s11) { Sequence.create!(sequence: 'ATT', sequence_type: 'DNA') }
  let!(:s12) { Sequence.create!(sequence: 'TTTTT', sequence_type: 'DNA') }
  let!(:s13) { Sequence.create!(sequence: 'AA', sequence_type: 'DNA') }
  let!(:s14) { Sequence.create!(sequence: 'CCCCC', sequence_type: 'DNA') }

  let!(:a1)  { SequenceRelationship::ForwardPrimer.create!(object_sequence: s1, subject_sequence: s5) } 
  let!(:a2)  { SequenceRelationship::ReversePrimer.create!(object_sequence: s1, subject_sequence: s9) } 

  let!(:a3)  { SequenceRelationship::ForwardPrimer.create!(object_sequence: s2, subject_sequence: s6) } 
  let!(:a4)  { SequenceRelationship::ReversePrimer.create!(object_sequence: s2, subject_sequence: s8) } 
  let!(:a5)  { SequenceRelationship::ReversePrimer.create!(object_sequence: s2, subject_sequence: s9) } 

  let!(:a6)  { SequenceRelationship::ForwardPrimer.create!(object_sequence: s3, subject_sequence: s6) } 
  let!(:a7)  { SequenceRelationship::ReversePrimer.create!(object_sequence: s3, subject_sequence: s8) } 

  let!(:a8)  { SequenceRelationship::ForwardPrimer.create!(object_sequence: s4, subject_sequence: s10) } 
  let!(:a9)  { SequenceRelationship::ReversePrimer.create!(object_sequence: s4, subject_sequence: s11) } 

  let!(:a10) { SequenceRelationship::BlastQuerySequence.create!(object_sequence: s12, subject_sequence: s13) } 

  context 'a descriptor (gene)' do
    let!(:descriptor) { Descriptor::Gene.create!(name: '28s') }

    context 'with no attributes' do
      specify 'returns no #sequences' do
        expect(descriptor.sequences).to eq([])
      end

      specify 'returns no #strict_and_sequences' do
        expect(descriptor.strict_and_sequences).to eq([])
      end

      specify 'returns no #sequences_matching_any_gene_attributes' do
        expect(descriptor.sequences_matching_any_gene_attributes).to eq([])
      end
    end

    context 'with two primers' do
      let!(:attribute5) { GeneAttribute.create!(descriptor: descriptor, sequence: s5, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
      let!(:attribute9) { GeneAttribute.create!(descriptor: descriptor, sequence: s9, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

      specify 'cached gene attribute sql persisted in database with gene attributes created' do
        descriptor.reload
        expect(descriptor.cached_gene_attribute_sql).not_to be_nil
      end

      specify 'with default logic #sequences returns target' do
        expect(descriptor.sequences).to contain_exactly(s1)
      end

      context 'with user provided OR logic' do
        before do
          descriptor.gene_attribute_logic = "#{attribute5.to_logic_literal} OR #{attribute9.to_logic_literal}"
          descriptor.save!
        end

        specify '#sequences returns target and others' do
          expect(descriptor.sequences.all.map(&:id)).to contain_exactly(s1.id, s2.id)
        end
      end

      context 'and a third primer' do
        let!(:attribute8) { GeneAttribute.create!(descriptor: descriptor, sequence: s8, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

        specify 'with default logic #sequences returns no sequences' do
          expect(descriptor.sequences.all).to contain_exactly()
        end

        context 'with user provided OR logic' do
          before do
            descriptor.gene_attribute_logic = "#{attribute5.to_logic_literal} AND (#{attribute8.to_logic_literal} OR #{attribute9.to_logic_literal})"
            descriptor.save!
          end

          specify '#sequences returns target' do
            expect(descriptor.sequences.all).to contain_exactly(s1)
          end
        end

        context 'and a forth primer' do
          let!(:attribute6) { GeneAttribute.create!(descriptor: descriptor, sequence: s6, sequence_relationship_type: SequenceRelationship::ForwardPrimer) }

          specify 'with default logic #sequences returns nothing' do
            expect(descriptor.sequences).to contain_exactly()
          end

          specify 'with #sequences_matching_any_gene_attributes' do
            expect(descriptor.sequences_matching_any_gene_attributes).to contain_exactly(s1, s2, s3)
          end

          context 'with user provided OR logic' do
            before do
              descriptor.gene_attribute_logic = "(#{attribute5.to_logic_literal} OR #{attribute6.to_logic_literal} ) AND ( #{attribute8.to_logic_literal} OR #{attribute9.to_logic_literal})"
              descriptor.save!
            end

            specify '#sequences returns target' do
              expect(descriptor.sequences.all.map(&:id)).to contain_exactly(s1.id, s2.id, s3.id)
            end
          end
        end
      end

    end
  end
end
