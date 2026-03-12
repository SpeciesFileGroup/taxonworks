require 'rails_helper'

# Original code mainly by chatgpt.
RSpec.describe 'Accepted OTU propagation to AnatomicalParts', type: :model do
  let(:otu1) { FactoryBot.create(:valid_otu) }
  let(:otu2) { FactoryBot.create(:valid_otu) }

  context 'propagates to AnatomicalParts' do
    def make_chain(top)
      # top -> ap1 -> ap2
      ap1 = FactoryBot.create(:valid_anatomical_part, ancestor: top)
      ap2 = FactoryBot.create(:valid_anatomical_part, ancestor: ap1)

      [ap1, ap2]
    end

    specify "updates descendant AnatomicalParts when accepted OTU changes by editing the top TaxonDetermination" do
      top = FactoryBot.create(:valid_specimen)
      # Two TDs, otu1 initially on top
      td1 = FactoryBot.create(:valid_taxon_determination, otu: otu1, taxon_determination_object: top)
      td2 = FactoryBot.create(:valid_taxon_determination, otu: otu2, taxon_determination_object: top)
      td2.insert_at(2) # ensure td1 (otu1) is first

      ap1, ap2 = make_chain(top)

      # Change accepted otu by editing position-1 TD
      top.taxon_determinations.order(:position).first.update!(otu: otu2)

      expect(ap1.reload.cached_otu_id).to eq(otu2.id)
      expect(ap2.reload.cached_otu_id).to eq(otu2.id)
    end

    specify "updates descendant AnatomicalParts when a new TaxonDetermination is added" do
      top = FactoryBot.create(:valid_specimen)
      FactoryBot.create(:valid_taxon_determination, otu: otu1, taxon_determination_object: top)

      ap1, ap2 = make_chain(top)

      expect(ap1.cached_otu_id).to eq(otu1.id)
      expect(ap2.cached_otu_id).to eq(otu1.id)

      td2 = FactoryBot.create(:valid_taxon_determination, otu: otu2, taxon_determination_object: top)

      expect(top.reload.current_otu.id).to eq(otu2.id)
      expect(ap1.reload.cached_otu_id).to eq(otu2.id)
      expect(ap2.reload.cached_otu_id).to eq(otu2.id)
    end

    specify "updates descendant AnatomicalParts when accepted TaxonDetermination changes by reordering" do
      top = FactoryBot.create(:valid_field_occurrence)
      FactoryBot.create(:valid_taxon_determination, otu: otu1, taxon_determination_object: top)
      td2 = FactoryBot.create(:valid_taxon_determination, otu: otu2, taxon_determination_object: top)

      ap1, ap2 = make_chain(top)

      # Move td2 (otu2) to the top
      td2.insert_at(1)

      expect(top.reload.current_otu.id).to eq(otu2.id)
      expect(ap1.reload.cached_otu_id).to eq(otu2.id)
      expect(ap2.reload.cached_otu_id).to eq(otu2.id)
    end

  end
end
