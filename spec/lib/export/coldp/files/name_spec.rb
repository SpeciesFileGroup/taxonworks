require 'rails_helper'

describe Export::Coldp::Files::Name, type: :model, group: :col do

  let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) } 

  let!(:genus) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :genus), name: 'Aus', parent: root_taxon_name) }
  let!(:genus2) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :genus), name: 'Bus', parent: root_taxon_name) }
  let!(:species) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :species), name: 'cus', parent: genus, verbatim_author: 'Smith', year_of_publication: 2000) }
  let!(:species2) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :species), name: 'cus', parent: genus, verbatim_author: 'Jones', year_of_publication: 2002) }
  let!(:synonymy) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: species, object_taxon_name: species2) }
  let!(:combination) { Combination.create!(species: species2, genus: genus2 ) }

  let!(:otu) { Otu.create!(taxon_name: root_taxon_name) } 

  # 40

  specify '#valid_names' do
    q = Export::Coldp::Files::Name.valid_names(otu)
    expect(q.all.size).to eq(6)
  end

end
