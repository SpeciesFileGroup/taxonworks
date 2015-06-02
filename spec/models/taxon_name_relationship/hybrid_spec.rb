require 'rails_helper'

describe TaxonNameRelationship::Hybrid, type: :model, group: [:nomenclature] do
  # must be executed first so that it is the root name used in the valid_hybrid
  let!(:root) { FactoryGirl.create(:root_taxon_name) }

  let(:hybrid_relationship) { TaxonNameRelationship::Hybrid.new }
  let(:valid_hybrid) { FactoryGirl.create(:valid_hybrid) }
  let(:g) { Protonym.create(name: 'Aus', parent: root, rank_class: Ranks.lookup(:icn, :genus)) }
  let(:s1) { Protonym.create(name: 'aus', parent: g, rank_class: Ranks.lookup(:icn, :species)) }

  context 'validate' do
    before {
      hybrid_relationship.object_taxon_name = valid_hybrid
    }

    specify 'when subject is species then relationship is valid' do
      hybrid_relationship.subject_taxon_name = s1
      expect(hybrid_relationship.valid?).to be_truthy
    end

    specify 'when subject is genus then relationship is invalid' do
      hybrid_relationship.subject_taxon_name = g 
      expect(hybrid_relationship.valid?).to be_falsey
      expect(hybrid_relationship.errors.include?(:subject_taxon_name_id)).to be_truthy
    end
  end

end
