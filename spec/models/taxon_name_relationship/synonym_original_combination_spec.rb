require 'rails_helper'

# Aus bus cus Smith, 1900 was described as a subspecies of Aus bus and is a subjective
# synonym of the species Zus mus. A protonym's name is built from its parent and rank, and
# its original combination from its original combination relationships.
#
# The fix for sv_synonym_linked_to_valid_name (sv_fix_subject_parent_update) moves a
# synonym to the parent and rank of its valid name. When the original combination is
# fully recorded, the name is rendered correctly after the fix. When it is not, the
# combination the name was published in is lost:
#
#   * no original combination: only the parent and rank record the published placement,
#     and after the fix nothing renders "Aus bus cus" (cached becomes "Zus cus")
#   * original genus and species only: TaxonWorks fills the name itself in at its current
#     rank; after the fix that rank is species, so the original combination renders as
#     "Aus bus"
#
# These examples check that the published combination is still recorded after the fix.
describe 'Synonym parent and original combination', type: :model, group: [:nomenclature, :soft_validation] do
  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let(:aus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:zus) { Protonym.create!(name: 'Zus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:bus) { Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, 'species'), parent: aus) }
  let(:mus) { Protonym.create!(name: 'mus', rank_class: Ranks.lookup(:iczn, 'species'), parent: zus) }
  let(:cus) do
    Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, 'subspecies'), parent: bus,
                     verbatim_author: 'Smith', year_of_publication: 1900)
  end
  let!(:synonymy) do
    TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.create!(subject_taxon_name: cus, object_taxon_name: mus)
  end

  def fix_synonym_parent
    synonymy.soft_validate(only_sets: :synonym_linked_to_valid_name)
    synonymy.fix_soft_validations
    cus.reload
  end

  specify 'the synonym is rendered as published in its published placement' do
    expect(cus.reload).to have_attributes(cached: 'Aus bus cus', cached_original_combination: nil)
  end

  specify 'the synonym is flagged as not having the parent and rank of its valid name' do
    synonymy.soft_validate(only_sets: :synonym_linked_to_valid_name)

    expect(synonymy.soft_validations.messages_on(:subject_taxon_name_id).size).to eq(1)
  end

  context 'without an original combination' do
    specify 'the published combination is still recorded after the fix' do
      fix_synonym_parent

      expect([cus.cached, cus.cached_original_combination]).to include('Aus bus cus')
    end
  end

  context 'with an original combination' do
    before do
      cus.update!(original_genus: aus, original_species: bus, original_subspecies: cus)
      cus.reload
    end

    specify 'the original combination is kept after the fix' do
      expect(cus.cached_original_combination).to eq('Aus bus cus')

      fix_synonym_parent

      expect(cus).to have_attributes(parent_id: zus.id, cached: 'Zus cus', cached_original_combination: 'Aus bus cus')
    end
  end

  # Incomplete data: the original genus and species are recorded but not the name itself
  # (see sv_original_combination_relationships). TaxonWorks fills the missing position
  # with the name at its current rank. After the fix cus is at species rank, a position
  # bus already holds, so the published combination must be kept some other way.
  context 'with an original combination that does not include the name itself' do
    before do
      cus.update!(original_genus: aus, original_species: bus)
      cus.reload
    end

    specify 'the original combination is kept after the fix' do
      expect(cus.cached_original_combination).to eq('Aus bus cus')

      fix_synonym_parent

      expect(cus.cached_original_combination).to eq('Aus bus cus')
    end
  end
end
