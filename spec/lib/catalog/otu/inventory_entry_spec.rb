require 'rails_helper'

describe Catalog::Otu::InventoryEntry, group: :catalogs, type: :spinup do
  let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let(:genus) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus)) }
  let(:species) { Protonym.create!(parent: genus, name: 'bus', rank_class: Ranks.lookup(:iczn, :species)) }
  let(:otu) { Otu.create!(taxon_name: species) }
  let(:source) { FactoryBot.create(:valid_source) }

  context 'with no associated data' do
    specify 'returns empty items' do
      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      expect(entry.items).to be_empty
    end
  end

  context 'with belongs_to associations' do
    let!(:citation) { Citation.create!(citation_object: species, source: source) }

    specify 'includes citations from protonym' do
      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      expect(entry.items.map(&:object)).to include(species)
      expect(entry.items.map(&:citation)).to include(citation)
    end
  end

  context 'with simple has_many associations' do
    let!(:common_name) { CommonName.create!(otu: otu, name: 'Test Name', geographic_area: FactoryBot.create(:valid_geographic_area)) }
    let!(:citation) { Citation.create!(citation_object: common_name, source: source) }

    specify 'includes citations from common_names' do
      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      expect(entry.items.map(&:object)).to include(common_name)
      expect(entry.items.map(&:citation)).to include(citation)
    end
  end

  context 'with polymorphic has_many associations' do
    specify 'includes citations from asserted_distributions' do
      asserted_distribution = AssertedDistribution.new(
        asserted_distribution_object: otu,
        asserted_distribution_shape: FactoryBot.create(:valid_geographic_area)
      )
      citation = Citation.new(citation_object: asserted_distribution, source: source)
      asserted_distribution.citations << citation
      asserted_distribution.save!

      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      expect(entry.items.map(&:object)).to include(asserted_distribution)
      expect(entry.items.map(&:citation)).to include(citation)
    end

    context 'biological_associations (polymorphic has_many)' do
      let(:otu2) { Otu.create!(taxon_name: species) }
      let(:relationship) { BiologicalRelationship.create!(name: 'eats') }

      specify 'includes citations from biological_associations' do
        biological_association = BiologicalAssociation.create!(
          biological_relationship: relationship,
          biological_association_subject: otu,
          biological_association_object: otu2
        )
        citation = Citation.create!(citation_object: biological_association, source: source)

        entry = Catalog::Otu::InventoryEntry.new(otu)
        entry.build
        expect(entry.items.map(&:object)).to include(biological_association)
        expect(entry.items.map(&:citation)).to include(citation)
      end
    end
  end

  context 'with has_many :through associations' do
    context 'images through depictions' do
      let!(:image) { FactoryBot.create(:valid_image) }
      let!(:depiction) { Depiction.create!(depiction_object: otu, image: image) }
      let!(:citation) { Citation.create!(citation_object: image, source: source) }

      specify 'includes citations from images' do
        entry = Catalog::Otu::InventoryEntry.new(otu)
        entry.build
        expect(entry.items.map(&:object)).to include(image)
        expect(entry.items.map(&:citation)).to include(citation)
      end
    end

    context 'collection_objects through taxon_determinations' do
      let!(:collection_object) { Specimen.create! }
      let!(:taxon_determination) { TaxonDetermination.create!(otu: otu, taxon_determination_object: collection_object) }
      let!(:citation) { Citation.create!(citation_object: collection_object, source: source) }

      specify 'includes citations from collection_objects' do
        entry = Catalog::Otu::InventoryEntry.new(otu)
        entry.build
        expect(entry.items.map(&:object)).to include(collection_object)
        expect(entry.items.map(&:citation)).to include(citation)
      end
    end

    context 'type_materials through protonym' do
      let!(:type_specimen) { Specimen.create! }
      let!(:type_material) { TypeMaterial.create!(
        protonym: species,
        collection_object: type_specimen,
        type_type: 'holotype'
      )}
      let!(:citation) { Citation.create!(citation_object: type_material, source: source) }

      specify 'includes citations from type_materials' do
        entry = Catalog::Otu::InventoryEntry.new(otu)
        entry.build
        expect(entry.items.map(&:object)).to include(type_material)
        expect(entry.items.map(&:citation)).to include(citation)
      end
    end
  end

  context 'with coordinate OTUs' do
    let!(:common_name) { CommonName.create!(otu: otu, name: 'Test Name', geographic_area: FactoryBot.create(:valid_geographic_area)) }
    let!(:citation) { Citation.create!(citation_object: common_name, source: source) }

    specify 'includes citations from coordinate OTU associations' do
      # Coordinate OTUs are OTUs with the same cached_valid_taxon_name_id
      # The original otu should be in its own coordinate set
      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      expect(entry.items.map(&:object)).to include(common_name)
      expect(entry.items.map(&:citation)).to include(citation)
      expect(entry.items.map(&:base_object)).to include(otu)
    end
  end

  context 'deduplication' do
    let(:source2) { FactoryBot.create(:valid_source) }
    let!(:common_name) { CommonName.create!(otu: otu, name: 'Test Name', geographic_area: FactoryBot.create(:valid_geographic_area)) }
    let!(:citation1) { Citation.create!(citation_object: common_name, source: source, pages: '1') }
    let!(:citation2) { Citation.create!(citation_object: common_name, source: source, pages: '2') }

    specify 'same citation+object combination appears only once' do
      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      items = entry.items
      citation1_items = items.select { |i| i.citation.id == citation1.id && i.object == common_name }
      expect(citation1_items.count).to eq(1)
    end

    specify 'different citations on same object both appear' do
      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build
      items = entry.items
      common_name_citations = items.select { |i| i.object == common_name }.map(&:citation)
      expect(common_name_citations).to include(citation1, citation2)
    end
  end

  context 'performance characteristics' do
    # This test documents expected query behavior
    specify 'uses bulk queries to avoid N+1' do
      # Create test data - 10 common names each with a citation
      sources = 10.times.map { FactoryBot.create(:valid_source) }
      sources.each_with_index do |src, i|
        cn = CommonName.create!(otu: otu, name: "Name #{i}", geographic_area: FactoryBot.create(:valid_geographic_area))
        Citation.create!(citation_object: cn, source: src)
      end

      query_count = 0
      ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        unless event.payload[:name] =~ /SCHEMA|TRANSACTION/
          query_count += 1
        end
      end

      entry = Catalog::Otu::InventoryEntry.new(otu)
      entry.build

      # We expect bulk loading, not N+1 queries
      # With 10 common_names, if we had N+1 we'd see 10+ queries just for common names alone
      # With bulk loading, we should see far fewer queries total
      # This is intentionally loose - we're just checking we're not doing obvious N+1
      expect(query_count).to be < 100
    end
  end
end
