require 'rails_helper'

# A sequence/extract/collection_object/descriptor scenario
RSpec.describe Sequence, type: :model, group: [:dna, :matrix, :descriptor] do

  let!(:object1) { Specimen.create! }
  let!(:object2) { Specimen.create! }
  let!(:object3) { Lot.create!(total: 5) }

  let!(:extract1) { Extract.create!(origin: object1, is_made_now: true )  }
  let!(:extract2) { Extract.create!(origin: object2, is_made_now: true)  }
  let!(:extract3) { Extract.create!(origin: object3, is_made_now: true)  }

  let!(:extract_other) { Extract.create!(origin: object1, is_made_now: true)  }

  let!(:fwd_primer) { Sequence.create!(sequence: 'TTT', sequence_type: :dna, name: 'FWD')  }
  let!(:rev_primer) { Sequence.create!(sequence: 'AAA', sequence_type: :dna, name: 'REV')  }
  
  let!(:descriptor) { Descriptor::Gene.create!(
    name: '28s', 
    gene_attributes_attributes: [
      {sequence: fwd_primer, sequence_relationship_type: 'SequenceRelationship::ForwardPrimer' }, 
      {sequence: rev_primer, sequence_relationship_type: 'SequenceRelationship::ReversePrimer'}
    ])}

  let!(:sequence1) { Sequence.create!(sequence: 'ACTGGTACACA', sequence_type: :dna, name: '28S', origin: extract1) }
  let!(:sequence2) { Sequence.create!(sequence: 'AGGTACACA', sequence_type: :dna, name: '28S', origin: extract2, describe_with: descriptor) }
  let!(:sequence3) { Sequence.create!(sequence: 'ACTTACACA', sequence_type: :dna, name: '28S', origin: extract3, describe_with: descriptor) }
  let!(:sequence_other) { Sequence.create!(sequence: 'ACTGGTACA', sequence_type: :dna, name: '28S') }

  let!(:randon_primer) { Sequence.create!(sequence: 'GGG', sequence_type: :dna) } 

  specify 'descriptors#sequences' do
    expect(descriptor.sequences).to contain_exactly(sequence2, sequence3)
  end

  context 'returning related collection objects' do
    specify 'via Sequence#name' do
      expect(CollectionObject.with_sequence_name('28S')).to contain_exactly(object1, object2, object3)
    end    

    specify 'via Descriptor#name' do
      expect(CollectionObject.via_descriptor(descriptor)).to contain_exactly(object2, object3)
    end    
  end

end
