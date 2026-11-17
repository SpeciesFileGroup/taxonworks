require 'rails_helper'

describe Queries::FieldOccurrence::Filter, type: :model, group: [:field_occurrences, :collecting_event, :filter] do

  let(:query) { Queries::FieldOccurrence::Filter.new({}) }

  context 'anatomical_part_query' do
    let!(:field_occurrence) { FactoryBot.create(:valid_field_occurrence) }
    let!(:anatomical_part) { FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence) }

    specify 'matches the origin FieldOccurrence' do
      query.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: anatomical_part.id)
      expect(query.all).to contain_exactly(field_occurrence)
    end

    specify 'ignores a non-AnatomicalPart descendant whose id collides with the anatomical part id' do
      shared_id = 91_000_003
      other_field_occurrence = FactoryBot.create(:valid_field_occurrence, id: shared_id)
      FactoryBot.create(:valid_extract, origin: other_field_occurrence, id: shared_id)

      ap = FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence, id: shared_id)

      query.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: ap.id)
      expect(query.all).to contain_exactly(field_occurrence)
    end
  end

  context 'determinations and hierarchical search' do
    let!(:ce) { FactoryBot.create(:valid_collecting_event) }

    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:genus1) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
    let!(:genus2) { Protonym.create!(name: 'Bus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) } # synonym

    let!(:species1) { Protonym.create!(name: 'cus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) }
    let!(:species2) { Protonym.create!(name: 'dus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) } # synonym

    let!(:tn1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
      subject_taxon_name: species2, object_taxon_name: species1) }

    let!(:tn2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
      subject_taxon_name: genus2, object_taxon_name: genus1) }

    let!(:o1) { Otu.create!(taxon_name: species1) } # valid,    parent genus1
    let!(:o2) { Otu.create!(taxon_name: species2) } # invalid,  parent genus1
    let!(:o3) { Otu.create!(taxon_name: genus1) }   # valid

    # fo1: created with otu o1 (position 1), then o2 added on top (position 1) -> o1 becomes historical
    let!(:fo1) { FieldOccurrence.create!(collecting_event: ce, total: 1, otu: o1) }
    let!(:fo2) { FieldOccurrence.create!(collecting_event: ce, total: 1, otu: o2) }
    let!(:fo3) { FieldOccurrence.create!(collecting_event: ce, total: 1, otu: o3) }

    before do
      FactoryBot.create(:valid_taxon_determination, taxon_determination_object: fo1, otu: o2) # current, fo1 historical: o1
      FactoryBot.create(:valid_taxon_determination, taxon_determination_object: fo2, otu: o1) # current, fo2 historical: o2
    end

    specify 'all field occurrences nested in a TaxonName regardless of status' do
      query.taxon_name_id = genus1.id
      query.validity = true # both valid and invalid
      query.taxon_name_current_determination = true # current and historical
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id, fo2.id, fo3.id)
    end

    specify 'all field occurrences nested in a TaxonName, valid only, any determination' do
      query.taxon_name_id = genus1.id
      # validity = nil (valid only, default)
      query.taxon_name_current_determination = true # current and historical
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id, fo2.id, fo3.id)
    end

    specify 'all field occurrences nested in a TaxonName, invalid only, any determination' do
      query.taxon_name_id = genus1.id
      query.validity = false
      query.taxon_name_current_determination = true # current and historical
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id, fo2.id)
    end

    specify 'all field occurrences nested in a TaxonName, valid and current (default)' do
      query.taxon_name_id = genus1.id
      # validity = nil (valid only, default)
      # taxon_name_current_determination = nil (current only, default)
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo2.id, fo3.id)
    end

    specify 'all field occurrences nested in a TaxonName, invalid only, current (default)' do
      query.taxon_name_id = genus1.id
      query.validity = false
      # taxon_name_current_determination = nil (current only, default)
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id)
    end

    specify 'all field occurrences nested in a TaxonName, invalid only, historical' do
      query.taxon_name_id = genus1.id
      query.validity = false
      query.taxon_name_current_determination = false
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo2.id)
    end

    specify 'all field occurrences for an exact TaxonName match, valid only (default)' do
      query.taxon_name_id = species1.id
      query.descendants = false
      # validity = nil (valid only, default)
      # taxon_name_current_determination = nil (current only, default)
      expect(query.all.pluck(:id)).to contain_exactly(fo2.id)
    end

    specify 'all field occurrences for an exact TaxonName match, invalid only' do
      query.taxon_name_id = species2.id
      query.descendants = false
      query.validity = false
      # taxon_name_current_determination = nil (current only, default)
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id)
    end
  end
end
