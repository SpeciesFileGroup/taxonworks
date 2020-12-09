require 'rails_helper'

RSpec.describe Descriptor::Gene, type: :model, group: [:descriptor, :observation_matrix, :dna] do
  let(:descriptor) { Descriptor::Gene.new(name: '28s') }

  let(:forward_primer) { FactoryBot.create(:valid_sequence) }
  let(:reverse_primer) { FactoryBot.create(:valid_sequence) }

  let(:attribute1) { GeneAttribute.new(descriptor: descriptor, sequence: forward_primer, sequence_relationship_type: SequenceRelationship::ForwardPrimer) } 
  let(:attribute2) { GeneAttribute.new(descriptor: descriptor, sequence: reverse_primer, sequence_relationship_type: SequenceRelationship::ReversePrimer) }

  context 'when gene attributes are saved to an "empty" descriptor' do
    before do 
      descriptor.save! 
      attribute1.save!
    end

    specify 'attributes are automatically appended' do
      expect(descriptor.gene_attribute_logic).to eq(attribute1.to_logic_literal)
    end

    specify 'append uses "AND"' do
      attribute2.save!
      expect(descriptor.gene_attribute_logic).to eq(attribute1.to_logic_literal + ' AND ' + attribute2.to_logic_literal)
    end
  end

  context '#gene_attribute_logic' do
    before do
      descriptor.save!
      attribute1.save! 
      attribute2.save!
    end 

    context 'when changed updates #cached_gene_attribute_logic_sql' do
      specify 'via user supplied values' do
        a = descriptor.cached_gene_attribute_sql 
        descriptor.gene_attribute_logic = "#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}"
        descriptor.save!
        expect(descriptor.cached_gene_attribute_sql).to_not eq(a)
      end

      specify 'via default addition of attributes' do
        descriptor.update!(gene_attribute_logic: "#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}")

        expect(
          descriptor.update!(
            gene_attribute_logic: "#{attribute1.to_logic_literal}",
            gene_attributes_attributes: [{id: attribute2.id , _destroy: true} ]
          )
        ).to be_truthy
      end 
    end

    context 'is valid when' do
      specify 'set by user and logic matches attributes' do
        descriptor.gene_attribute_logic = "#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}"
        expect(descriptor.save).to be_truthy
      end

      specify 'logic and attribute changes simultaneously' do
        descriptor.gene_attribute_logic = "#{attribute1.to_logic_literal} OR #{attribute2.to_logic_literal}"
        expect(descriptor.save).to be_truthy
      end
    end

    context 'is invalid when' do
      specify 'set by user and logic does not match attributes' do
        descriptor.gene_attribute_logic = "FOO.1 OR #{attribute2.to_logic_literal}"
        descriptor.save
        expect(descriptor.errors.include?(:gene_attribute_logic)).to be_truthy
      end

      specify 'contains uncompressable terms' do
        descriptor.gene_attribute_logic = "FOO2.1 OR #{attribute2.to_logic_literal}"
        descriptor.save
        expect(descriptor.errors.include?(:gene_attribute_logic)).to be_truthy
      end

      specify 'set by user and invalid form' do
        descriptor.gene_attribute_logic = "FOOr1 OR #{attribute2.to_logic_literal}"
        descriptor.save
        expect(descriptor.errors.include?(:gene_attribute_logic)).to be_truthy
      end
    end

    context 'and related methods' do
      specify '#sequence_query_set' do
        expect(descriptor.sequence_query_set).to eq(
          [
            [[attribute1.sequence_relationship_type, attribute1.to_param], [attribute2.sequence_relationship_type, attribute2.to_param ]]
          ]
        )
      end
    end
  end

  context 'logic helpers' do
    let(:expression) { '(A.1 OR B.2) AND (C.3 OR D:E.42)' }

    before { descriptor.gene_attribute_logic = expression } 

    specify '#gene_attribute_term_index' do
      expect(descriptor.gene_attribute_term_index).to eq( {'A.1' => 'a', 'B.2' => 'b', 'C.3' => 'c', 'D:E.42' => 'd'} )
    end

    specify '#compress_logic' do
      expect(descriptor.compress_logic).to eq('(a+b).(c+d)')

      # Make sure the compress logic replaces whole words and not just partial words
      # e.g A.10 matches only A.10 and NOT A.1
      descriptor.gene_attribute_logic = '(A.1 OR B.2) AND (A.10 OR B.20)'
      expect(descriptor.compress_logic).to eq('(a+b).(c+d)')
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

end
