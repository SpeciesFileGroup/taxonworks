require 'rails_helper'

describe OtusHelper, type: :helper do
  let(:otu) { FactoryBot.create(:valid_otu, name: 'voluptas') }

  specify '#otu_tag' do
    expect(helper.otu_tag(otu)).to eq('<span class="otu_tag"><span class="otu_tag_otu_name" title="1">voluptas</span></span>')
  end

  specify '#otu_link' do
    expect(helper.otu_link(otu)).to have_link('voluptas')
  end

  specify '#otu_search_form' do
    expect(helper.otus_search_form).to have_field('otu_id_for_quick_search_form')
  end

  specify '#otu_catalog' do
    f = FactoryBot.create(:iczn_family, name: 'Cicadidae')
    g1 = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: f)
    g2 = Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: f)
    t = Protonym.create!(name: 'Ausini', rank_class: Ranks.lookup(:iczn, :tribe), parent: f)
    sf = Protonym.create!(name: 'Cicadinae', rank_class: Ranks.lookup(:iczn, :subfamily), parent: f)

    o1 = Otu.create!(taxon_name: f)
    o2 = Otu.create!(taxon_name: g1)

    o5 = Otu.create!(taxon_name: sf)
    o4 = Otu.create!(taxon_name: t)

    o3 = Otu.create!(taxon_name: g2)


    expect(helper.otu_descendants_and_synonyms(o1)[:descendants].collect{|i| i[:otu_id]}).to eq([o5.id, o4.id, o3.id, o2.id])
  end

  # Originally written mostly by chatgpt.
  describe '#add_distribution_geo_json' do
    let!(:protonym) { FactoryBot.create(:relationship_species) }
    let!(:otu)      { FactoryBot.create(:valid_otu, taxon_name: protonym) }

    let!(:ce_paratype) { FactoryBot.create(:valid_collecting_event) }
    let!(:ce_holotype) { FactoryBot.create(:valid_collecting_event) }
    let!(:gr_paratype) { FactoryBot.create(:valid_georeference, collecting_event: ce_paratype) }
    let!(:gr_holotype) { FactoryBot.create(:valid_georeference, collecting_event: ce_holotype) }

    let!(:co_without_td) { FactoryBot.create(:valid_specimen) }
    let!(:co_paratype)   { FactoryBot.create(:valid_specimen, collecting_event: ce_paratype) }
    let!(:co_holotype)   { FactoryBot.create(:valid_specimen, collecting_event: ce_holotype) }

    before do
      FactoryBot.create(:taxon_determination, otu: otu, taxon_determination_object: co_paratype)
      FactoryBot.create(:taxon_determination, otu: otu, taxon_determination_object: co_holotype)

      FactoryBot.create(:type_material, type_type: 'paratype', protonym: protonym, collection_object: co_paratype)
      FactoryBot.create(:type_material, type_type: 'holotype', protonym: protonym, collection_object: co_holotype)
    end

    describe 'Collection objects and type materials' do
      def type_material_labels_for(otu)
        h = helper.geojson_for_otu(otu)
        features = helper.add_distribution_geo_json(otu, h).fetch('features')

        features
          .map { |f| f.dig('properties', 'base') }
          .compact
          .select { |b| b['type'] == 'TypeMaterial' }
          .map { |b| b['label'].to_s }
      end

      specify 'includes ICZN primary type (holotype) as a TypeMaterial feature' do
        labels = type_material_labels_for(otu)
        expect(labels.any? { |l| l.start_with?('holotype') }).to be(true)
      end

      specify 'excludes ICZN non-primary type (paratype) from TypeMaterial features' do
        labels = type_material_labels_for(otu)
        expect(labels.any? { |l| l.start_with?('paratype') }).to be(false)
      end

      specify 'does not include undetermined collection object as a TypeMaterial feature' do
        labels = type_material_labels_for(otu)
        # Only holotype should survive if you’re filtering to ICZN primary types
        expect(labels.count).to eq(1)
        expect(labels.first).to start_with('holotype')
      end

      specify 'does not include type material on an invalid name as a TypeMaterial feature' do
        junior_protonym = protonym
        senior_protonym = FactoryBot.create(:relationship_species)
        TaxonNameRelationship.create!(subject_taxon_name: junior_protonym,
          object_taxon_name: senior_protonym,
          type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
        labels = type_material_labels_for(otu)
        expect(labels.count).to eq(0)
      end

      specify 'emits CollectionObject features for collection objects with determinations' do
        h = helper.geojson_for_otu(otu)
        features = helper.add_distribution_geo_json(otu, h).fetch('features')

        co_ids = features
          .map { |f| f.dig('properties', 'base') }
          .compact
          .select { |b| b['type'] == 'CollectionObject' }
          .map { |b| b['id'] }

        expect(co_ids).to contain_exactly(co_paratype.id, co_holotype.id)
      end
    end

    describe 'Asserted distributions' do
      let!(:ad_geographic_area) do
        FactoryBot.create(:valid_geographic_area_asserted_distribution,
          asserted_distribution_object: otu)
      end

      let!(:ad_gazetteer) do
        FactoryBot.create(:valid_gazetteer_asserted_distribution,
          asserted_distribution_object: otu,
          is_absent: true)
      end

      # Ensure the GA has a shape so it emits a feature
      before do
        FactoryBot.create(
          :valid_geographic_areas_geographic_item,
          geographic_area: ad_geographic_area.asserted_distribution_shape
        )
      end

      def ad_features_for(otu)
        h = helper.geojson_for_otu(otu)
        features = helper.add_distribution_geo_json(otu, h).fetch('features')

        features
          .select { |f| f.dig('properties', 'base', 'type') == 'AssertedDistribution' }
      end

      specify 'emits AssertedDistribution features for both GeographicArea and Gazetteer shapes' do
        features = ad_features_for(otu)

        base_ids = features.map { |f| f.dig('properties', 'base', 'id') }
        shape_types = features.map { |f| f.dig('properties', 'shape', 'type') }

        expect(base_ids).to contain_exactly(ad_geographic_area.id, ad_gazetteer.id)
        expect(shape_types).to contain_exactly('GeographicArea', 'Gazetteer')
        expect(features.all? { |f| f['geometry'].present? }).to be(true)
      end

      specify 'preserves shape' do
        features = ad_features_for(otu)

        # Shape/type preserved per AD
        ga_feature = features.find { |f| f.dig('properties', 'base', 'id') == ad_geographic_area.id }
        gz_feature = features.find { |f| f.dig('properties', 'base', 'id') == ad_gazetteer.id }

        expect(ga_feature.dig('properties', 'shape', 'type')).to eq('GeographicArea')
        expect(gz_feature.dig('properties', 'shape', 'type')).to eq('Gazetteer')
      end

      specify 'preserves is_absent' do
        features = ad_features_for(otu)

        ga_feature = features.find { |f| f.dig('properties', 'base', 'id') == ad_geographic_area.id }
        gz_feature = features.find { |f| f.dig('properties', 'base', 'id') == ad_gazetteer.id }

        # is_absent preserved (we set true on gazetteer AD)
        expect(ga_feature.dig('properties', 'is_absent')).to eq(nil)
        expect(gz_feature.dig('properties', 'is_absent')).to eq(true)
      end
    end

    describe 'deduplication via seen_shapes' do
      let!(:otu2) { FactoryBot.create(:valid_otu) }
      let!(:shared_ga) { FactoryBot.create(:valid_geographic_area) }

      let!(:ad1) do
        FactoryBot.create(:valid_geographic_area_asserted_distribution,
          asserted_distribution_object: otu,
          asserted_distribution_shape: shared_ga)
      end

      let!(:ad2) do
        FactoryBot.create(:valid_geographic_area_asserted_distribution,
          asserted_distribution_object: otu2,
          asserted_distribution_shape: shared_ga)
      end

      before do
        FactoryBot.create(:valid_geographic_areas_geographic_item, geographic_area: shared_ga)
      end

      def ad_features_for_shared_ga(h)
        h['features'].select { |f|
          f.dig('properties', 'base', 'type') == 'AssertedDistribution' &&
          f.dig('properties', 'shape', 'id') == shared_ga.id
        }
      end

      specify 'includes all records but only fetches geometry once per shape when seen_shapes is provided' do
        h = helper.geojson_for_otu(otu)
        seen = { field_occurrences: {}, collection_objects: {}, asserted_distributions: {}, type_materials: {} }

        helper.add_distribution_geo_json(otu, h, seen)
        helper.add_distribution_geo_json(otu2, h, seen)

        features = ad_features_for_shared_ga(h)
        expect(features.count).to eq(2)
        expect(features.count { |f| f['geometry'].present? }).to eq(1)
        expect(features.count { |f| f['geometry'].nil? }).to eq(1)
      end

      specify 'includes geometry on all records when seen_shapes is not provided' do
        h = helper.geojson_for_otu(otu)

        helper.add_distribution_geo_json(otu, h)
        helper.add_distribution_geo_json(otu2, h)

        features = ad_features_for_shared_ga(h)
        expect(features.count).to eq(2)
        expect(features.all? { |f| f['geometry'].present? }).to be(true)
      end

      # Georeference dedup is narrower than geographic area dedup: it only fires when
      # records share the *same collecting event* (and thus the same georeference object).
      # Two collecting events at the same location have distinct georeference IDs and
      # will not be deduplicated even if they produce identical geometries.
      describe 'georeference-based shapes (collection objects sharing a collecting event)' do
        let!(:shared_ce) { FactoryBot.create(:valid_collecting_event) }
        let!(:shared_gr) { FactoryBot.create(:valid_georeference, collecting_event: shared_ce) }

        let!(:co1) { FactoryBot.create(:valid_specimen, collecting_event: shared_ce) }
        let!(:co2) { FactoryBot.create(:valid_specimen, collecting_event: shared_ce) }

        before do
          FactoryBot.create(:taxon_determination, otu: otu,  taxon_determination_object: co1)
          FactoryBot.create(:taxon_determination, otu: otu2, taxon_determination_object: co2)
        end

        def co_features_for_shared_gr(h)
          h['features'].select { |f|
            f.dig('properties', 'base', 'type') == 'CollectionObject' &&
            f.dig('properties', 'shape', 'type') == 'Georeference' &&
            f.dig('properties', 'shape', 'id') == shared_gr.id
          }
        end

        specify 'includes all records but only fetches geometry once when OTUs share a collecting event' do
          h = helper.geojson_for_otu(otu)
          seen = { field_occurrences: {}, collection_objects: {}, asserted_distributions: {}, type_materials: {} }

          helper.add_distribution_geo_json(otu,  h, seen)
          helper.add_distribution_geo_json(otu2, h, seen)

          features = co_features_for_shared_gr(h)
          expect(features.count).to eq(2)
          expect(features.count { |f| f['geometry'].present? }).to eq(1)
          expect(features.count { |f| f['geometry'].nil? }).to eq(1)
        end

        specify 'geo_json_shape_key returns the same shape id as geo_json_data for a georeference' do
          shape_key = shared_ce.geo_json_shape_key
          expect(shape_key).to eq(['Georeference', shared_gr.id])

          geometry, shape_type, shape_id = shared_ce.geo_json_data
          expect(shape_type).to eq('Georeference')
          expect(shape_id).to eq(shared_gr.id)
          expect(geometry).to be_present
        end
      end

      # When a collecting event has no georeference and falls back to its geographic area,
      # the shape key is ['GeographicArea', geographic_area_id]. Two *different* collecting
      # events that reference the same geographic area share that key and deduplicate —
      # this is the broader and more impactful case for collection objects.
      describe 'geographic-area-based shapes (collection objects on different CEs sharing a GA)' do
        let!(:shared_ga) { FactoryBot.create(:valid_geographic_area) }

        # Two separate collecting events, no georeferences, both assigned to shared_ga
        let!(:ce1) { FactoryBot.create(:valid_collecting_event, geographic_area: shared_ga) }
        let!(:ce2) { FactoryBot.create(:valid_collecting_event, geographic_area: shared_ga) }

        let!(:co1) { FactoryBot.create(:valid_specimen, collecting_event: ce1) }
        let!(:co2) { FactoryBot.create(:valid_specimen, collecting_event: ce2) }

        before do
          FactoryBot.create(:valid_geographic_areas_geographic_item, geographic_area: shared_ga)
          FactoryBot.create(:taxon_determination, otu: otu,  taxon_determination_object: co1)
          FactoryBot.create(:taxon_determination, otu: otu2, taxon_determination_object: co2)
        end

        def co_features_for_shared_ga(h)
          h['features'].select { |f|
            f.dig('properties', 'base', 'type') == 'CollectionObject' &&
            f.dig('properties', 'shape', 'type') == 'GeographicArea' &&
            f.dig('properties', 'shape', 'id') == shared_ga.id
          }
        end

        specify 'includes all records but only fetches geometry once when OTUs have COs on different CEs sharing a GA' do
          h = helper.geojson_for_otu(otu)
          seen = { field_occurrences: {}, collection_objects: {}, asserted_distributions: {}, type_materials: {} }

          helper.add_distribution_geo_json(otu,  h, seen)
          helper.add_distribution_geo_json(otu2, h, seen)

          features = co_features_for_shared_ga(h)
          expect(features.count).to eq(2)
          expect(features.count { |f| f['geometry'].present? }).to eq(1)
          expect(features.count { |f| f['geometry'].nil? }).to eq(1)
        end

        specify 'geo_json_shape_key returns GeographicArea key when CE has no georeference' do
          expect(ce1.geo_json_shape_key).to eq(['GeographicArea', shared_ga.id])
          expect(ce2.geo_json_shape_key).to eq(['GeographicArea', shared_ga.id])
        end
      end
    end
  end

end
