require 'rails_helper'

RSpec.describe GeneAttribute, type: :model do
  let(:gene_attribute) {GeneAttribute.new}

  context 'validation' do
    context 'fails when not given' do
      before(:each) { gene_attribute.valid? }

      specify 'descriptor' do
        expect(gene_attribute.errors.include?(:descriptor)).to be_truthy
      end

      specify 'sequence' do
        expect(gene_attribute.errors.include?(:sequence)).to be_truthy
      end
    end
    
    context 'passes when provided a' do
      specify 'descriptor_id and sequence_id' do
        gene_attribute = FactoryBot.create(:valid_gene_attribute)
        expect(gene_attribute.valid?).to be_truthy
      end
    end
  end

  context '#to_logic_literal' do
    before do
      gene_attribute.sequence_relationship_type = 'SequenceRelationship::ForwardPrimer'
      gene_attribute.sequence = FactoryBot.create(:valid_sequence)
      gene_attribute.descriptor = FactoryBot.create(:valid_descriptor_gene)
      gene_attribute.save!
    end

    specify 'includes type and id' do
      expect(gene_attribute.to_logic_literal).to eq("SequenceRelationship::ForwardPrimer.#{gene_attribute.sequence_id}")
    end
  end

end
