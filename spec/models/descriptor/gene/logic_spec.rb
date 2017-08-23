require 'rails_helper'

RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :matrix, :dna] do
  let(:descriptor) { Descriptor::Gene.new(name: '28s') }

  let(:forward_primer) { FactoryGirl.create(:valid_sequence) }
  let(:reverse_primer) { FactoryGirl.create(:valid_sequence) }

  let(:attribute1) { GeneAttribute.new(descriptor: descriptor, sequence: forward_primer, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
  let(:attribute2) { GeneAttribute.new(descriptor: descriptor, sequence: reverse_primer, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

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

  context 'a descriptor with attributes' do
    before do
      descriptor.save!
      attribute1.save!
      attribute2.save!
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
        expect(descriptor.build_gene_attribute_logic_sql(l)).to eq(
          %Q{"sequence_relationships"."type" = 'SequenceRelationship::ForwardPrimer' AND "sequence_relationships"."subject_sequence_id" = 999}  
        )
      end

      specify 'lezz' do
        l = 'A.(B+C)'
        expect(descriptor.or_queries(l)).to contain_exactly('AB', 'AC')
      end

      context 'axiomization' do
        let(:expression) { '(A.1 OR B.2) AND (C.3 OR D:E.42)' }

        before do
          descriptor.gene_attribute_logic = expression
        end

        specify '#axiomize_gene_attribute_logic' do
          expect(descriptor.axiomize_gene_attribute_logic).to eq( {'A.1' => 'a', 'B.2' => 'b', 'C.3' => 'c', 'D:E.42' => 'd'} )
        end

        specify '#compress_logic' do
          expect(descriptor.compress_logic).to eq('(a+b).(c+d)')
        end

        specify '#parse_logic' do
          expect(descriptor.parse_logic('(a+b).(c+d)')).to eq('ac+ad+bc+bd')
        end

        specify '#or_queries' do
          expect(descriptor.or_queries('(a+b).(c+d)')).to eq(%w{ac ad bc bd})
        end

        specify '#attributes_from_or_queries' do
          expect(descriptor.attributes_from_or_queries(%w{ac ad bc bd})).to eq(
            [ 
              [ ['A', '1'], ['C', '3'] ],    # ac 
              [ ['A', '1'], ['D:E', '42'] ], # ad
              [ ['B', '2'], ['C', '3'] ],    # bc
              [ ['B', '2'], ['D:E', '42'] ]  # bd
            ]  
          )
        end
      end

      specify '#sequence_query_set' do
        expect(descriptor.sequence_query_set).to eq(
            [
              [[attribute1.sequence_relationship_type, attribute1.to_param], [attribute2.sequence_relationship_type, attribute2.to_param ]]
            ]
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
