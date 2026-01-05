# frozen_string_literal: true

# Shared helpers to speed up DwCA checklist export specs.
#
# Provides:
# - One-time fixture creation (outside per-example transactions)
# - A small cache for generated DwCA CSV strings (frozen master + per-call dup)
#
# NOTE: Because the suite uses DatabaseCleaner with :transaction for each example,
# records created in before(:context) will persist across examples. We therefore
# provide an explicit cleanup method that specs MUST call in after(:context).
module DwcaChecklistSpecSupport
  module Fixtures
    module_function

    def setup_once!
      return if defined?(@setup_done) && @setup_done

      # Base OTUs
      otu1 = FactoryBot.create(:valid_otu)
      otu2 = FactoryBot.create(:valid_otu)
      otu3 = FactoryBot.create(:valid_otu)
      otu4 = FactoryBot.create(:valid_otu) # excluded from scoped exports

      # Create taxon names with full classification including class for testing
      root    = FactoryBot.create(:root_taxon_name)
      kingdom = Protonym.create!(name: 'Animalia', rank_class: Ranks.lookup(:iczn, :kingdom), parent: root)
      phylum  = Protonym.create!(name: 'Arthropoda', rank_class: Ranks.lookup(:iczn, :phylum), parent: kingdom)
      klass   = Protonym.create!(name: 'Insecta', rank_class: Ranks.lookup(:iczn, :class), parent: phylum)
      order   = Protonym.create!(name: 'Lepidoptera', rank_class: Ranks.lookup(:iczn, :order), parent: klass)
      family  = Protonym.create!(name: 'Noctuidae', rank_class: Ranks.lookup(:iczn, :family), parent: order)
      genus   = Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family)

      taxon_name1 = Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus)
      taxon_name2 = Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, :species), parent: genus)
      taxon_name3 = Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: genus)

      otu1.update!(taxon_name: taxon_name1)
      otu2.update!(taxon_name: taxon_name2)
      otu3.update!(taxon_name: taxon_name3)

      # Create 3 specimens + determinations + occurrences (core export drivers)
      [otu1, otu2, otu3].each do |otu|
        specimen = FactoryBot.create(:valid_specimen)
        FactoryBot.create(:valid_taxon_determination, otu: otu, taxon_determination_object: specimen)
        specimen.get_dwc_occurrence
      end

      # Distribution extension fixtures (asserted distributions)
      ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu1)
      ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu2)
      ad1.get_dwc_occurrence
      ad2.get_dwc_occurrence

      # References extension fixtures (sources + citations)
      source1 = FactoryBot.create(:valid_source)
      source2 = FactoryBot.create(:valid_source)
      # Cite sources on taxon names used by the checklist
      FactoryBot.create(:valid_citation, citation_object: taxon_name1, source: source1)
      FactoryBot.create(:valid_citation, citation_object: taxon_name2, source: source2)

      # Types/specimens extension fixtures (type material)
      # Keep minimal: create a type specimen for one taxon
      type_specimen = FactoryBot.create(:valid_specimen)
      FactoryBot.create(:valid_type_material, protonym: taxon_name1, collection_object: type_specimen)

      # Vernacular name extension fixtures (CommonName + Language)
      language_en = FactoryBot.create(:valid_language, alpha_2: 'en')
      FactoryBot.create(:valid_common_name, otu: otu1, name: 'Test common name', language: language_en)

      # Description extension fixtures (PublicContent built from Content + Topic + Language)
      topic_morphology = FactoryBot.create(:valid_topic, name: 'Morphology')
      content = FactoryBot.create(:valid_content, otu: otu1, topic: topic_morphology, text: 'Test **markdown**.', language: language_en)
      PublicContent.create!(content: content, topic: topic_morphology, text: content.text, otu: otu1)
      @ids = {
        otu1: otu1.id, otu2: otu2.id, otu3: otu3.id, otu4: otu4.id,
        taxon_name1: taxon_name1.id, taxon_name2: taxon_name2.id, taxon_name3: taxon_name3.id
      }

      @setup_done = true
    end

    def ids
      setup_once!
      @ids.dup
    end

    def scope_otu_ids
      setup_once!
      i = @ids
      [i[:otu1], i[:otu2], i[:otu3]]
    end

    def cleanup!
      # Truncate everything created by this support. This is faster and safer than
      # trying to chase all dependent rows.
      DatabaseCleaner.clean_with(:truncation, except: %w(spatial_ref_sys))
      DwcaChecklistSpecSupport::CsvCache.clear!
      remove_instance_variable(:@setup_done) if defined?(@setup_done)
      remove_instance_variable(:@ids) if defined?(@ids)
    end
  end

  module CsvCache
    module_function

    def fetch(key)
      @cache ||= {}
      @cache[key] ||= yield.freeze
      @cache[key].dup
    end

    def clear!
      @cache = {}
    end
  end
end
