require 'rails_helper'

RSpec.describe Project, '#unify', type: :model do
  let(:user)           { FactoryBot.create(:valid_user) }
  let(:source_project) { FactoryBot.create(:valid_project, name: 'Source Project') }
  let(:target_project) { FactoryBot.create(:valid_project, name: 'Target Project') }

  describe 'basic unification' do
    context 'with empty projects' do
      it 'unifies without errors' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true
        expect(result[:errors]).to be_empty
      end

      it 'returns proper result structure' do
        result = target_project.unify(source_project, preview: true, user_id: user.id)

        expect(result).to include(
          :unified,
          :preview_mode,
          :source_project_id,
          :target_project_id,
          :started_at,
          :completed_at,
          :duration_seconds,
          :statistics,
          :details_by_model,
          :conflicts,
          :errors
        )
      end
    end

    context 'with fast-track models' do
      let!(:collection_objects) do
        10.times.map { FactoryBot.create(:valid_collection_object, project: source_project) }
      end

      it 'bulk updates all records' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(CollectionObject.where(project_id: target_project.id).count).to eq(10)
        expect(CollectionObject.where(project_id: source_project.id).count).to eq(0)
        expect(result[:unified]).to be true
      end

      it 'reports correct statistics' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:statistics][:records_migrated]).to be >= 10
        expect(result[:statistics][:slow_track_count]).to be > 0
      end
    end
  end

  describe 'TaxonName hierarchy handling' do
    let!(:source_root) { source_project.root_taxon_name }
    let!(:target_root) { target_project.root_taxon_name }

    context 'with simple hierarchy' do
      let!(:genus) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Aus',
          parent: source_root,
          project: source_project
        )
      end

      let!(:species) do
        FactoryBot.create(
          :relationship_species,
          name: 'bus',
          parent: genus,
          project: source_project
        )
      end

      it 'moves entire tree under target root' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        genus.reload
        species.reload
        source_root.reload

        expect(genus.project_id).to eq(target_project.id)
        expect(species.project_id).to eq(target_project.id)
        expect(genus.parent).to eq(target_root) # genus moved directly under target root
        expect(species.parent).to eq(genus)
        expect(result[:unified]).to be true
      end

      it 'preserves closure_tree integrity' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        genus.reload
        species.reload

        expect(genus.ancestors.unscope(:order)).to include(target_root)
        expect(species.ancestors.unscope(:order)).to include(genus, target_root)
        expect(target_root.descendants.unscope(:order)).to include(genus, species)
      end

      it 'counts TaxonNames in statistics' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:statistics][:special_track_count]).to eq(2) # genus + species (root is not moved)
      end
    end

    context 'with custom root_taxon_name_id' do
      let!(:target_family) do
        FactoryBot.create(
          :relationship_family,
          name: 'Targetidae',
          parent: target_root,
          project: target_project
        )
      end

      let!(:source_genus) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Sourcegenus',
          parent: source_root,
          project: source_project
        )
      end

      it 'nests under specified taxon' do
        result = target_project.unify(
          source_project,
          root_taxon_name_id: target_family.id,
          preview: false,
          user_id: user.id
        )

        source_genus.reload

        expect(source_genus.parent).to eq(target_family) # children of root moved to target_family
        expect(source_genus.project_id).to eq(target_project.id)
        expect(result[:unified]).to be true
      end

      it 'rejects invalid root_taxon_name_id' do
        invalid_id = 999999

        expect {
          target_project.unify(
            source_project,
            root_taxon_name_id: invalid_id,
            preview: false,
              user_id: user.id
          )
        }.to raise_error(ArgumentError, /root_taxon_name_id/)
      end

      it 'rejects root_taxon_name_id from wrong project' do
        wrong_project = FactoryBot.create(:valid_project, name: 'Wrong Project')
        wrong_taxon = FactoryBot.create(
          :relationship_genus,
          name: 'Wronggenus',
          parent: wrong_project.root_taxon_name,
          project: wrong_project
        )

        expect {
          target_project.unify(
            source_project,
            root_taxon_name_id: wrong_taxon.id,
            preview: false,
              user_id: user.id
          )
        }.to raise_error(ArgumentError, /must belong to target project/)
      end
    end

    context 'with complex hierarchy' do
      let!(:family) do
        FactoryBot.create(
          :relationship_family,
          name: 'Familyidae',
          parent: source_root,
          project: source_project
        )
      end

      let!(:genus1) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Genusone',
          parent: family,
          project: source_project
        )
      end

      let!(:genus2) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Genustwo',
          parent: family,
          project: source_project
        )
      end

      let!(:species1) do
        FactoryBot.create(
          :relationship_species,
          name: 'speciesone',
          parent: genus1,
          project: source_project
        )
      end

      let!(:species2) do
        FactoryBot.create(
          :relationship_species,
          name: 'speciestwo',
          parent: genus2,
          project: source_project
        )
      end

      it 'preserves entire hierarchy structure' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        family.reload
        genus1.reload
        genus2.reload
        species1.reload
        species2.reload

        expect(family.parent).to eq(target_root)
        expect(genus1.parent).to eq(family)
        expect(genus2.parent).to eq(family)
        expect(species1.parent).to eq(genus1)
        expect(species2.parent).to eq(genus2)
      end

      it 'updates all project_ids' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        [family, genus1, genus2, species1, species2].each do |taxon|
          taxon.reload
          expect(taxon.project_id).to eq(target_project.id)
        end
      end

      it 'maintains cached values after migration' do
        result = target_project.unify(source_project, preview: false, user_id: user.id, skip_cached_rebuild: false)

        expect(result[:cached_rebuild]).to be_present
        expect(result[:cached_rebuild][:models_rebuilt]).to be > 0
      end
    end

    context 'with TaxonNameRelationships' do
      let!(:genus) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Testgenus',
          parent: source_root,
          project: source_project
        )
      end

      let!(:species) do
        FactoryBot.create(
          :relationship_species,
          name: 'testspecies',
          parent: genus,
          project: source_project
        )
      end

      let!(:another_species) do
        FactoryBot.create(
          :relationship_species,
          name: 'anotherspecies',
          parent: genus,
          project: source_project
        )
      end

      let!(:relationship) do
        TaxonNameRelationship.create!(
          type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          subject_taxon_name: species,
          object_taxon_name: another_species,
          project: source_project
        )
      end

      it 'migrates relationships with taxon names' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        relationship.reload
        expect(relationship.project_id).to eq(target_project.id)
      end
    end

    context 'with TaxonNameClassifications' do
      let!(:genus) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Classifiedgenus',
          parent: source_root,
          project: source_project
        )
      end

      let!(:classification) do
        TaxonNameClassification.create!(
          type: 'TaxonNameClassification::Iczn::Available',
          taxon_name: genus,
          project: source_project
        )
      end

      it 'migrates classifications' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        classification.reload
        expect(classification.project_id).to eq(target_project.id)
      end
    end
  end

  describe 'uniqueness conflict handling' do
    context 'with ObservationMatrix name conflict' do
      let!(:shared_name) { 'Shared Matrix Name' }

      let!(:source_matrix) do
        FactoryBot.create(:observation_matrix, name: shared_name, project: source_project)
      end

      let!(:target_matrix) do
        FactoryBot.create(:observation_matrix, name: shared_name, project: target_project)
      end

      it 'reports the conflict with model and record detail' do
        result = target_project.unify(source_project, preview: true, user_id: user.id)

        expect(result[:conflicts]).not_to be_empty
        conflict = result[:conflicts].first
        expect(conflict[:model]).to eq('ObservationMatrix')
        expect(conflict[:id]).to eq(source_matrix.id)
        expect(conflict[:conflict_fields]).to include(:name)
      end

      it 'rolls back in preview mode' do
        result = target_project.unify(source_project, preview: true, user_id: user.id)

        expect(result[:preview_mode]).to be true
        expect(result[:rollback_performed]).to be true
      end

      it 'does not unify when conflicts exist' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be false
        expect(result[:conflicts]).not_to be_empty
      end

      it 'rolls back all changes when conflicts exist in actual mode' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:rollback_performed]).to be true
        source_matrix.reload
        expect(source_matrix.project_id).to eq(source_project.id)
      end
    end

    context 'without conflicts' do
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:note) { FactoryBot.create(:note, note_object: source_otu, project: source_project, text: 'Test note') }

      it 'migrates without conflicts' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true
        expect(result[:conflicts]).to be_empty

        note.reload
        expect(note.project_id).to eq(target_project.id)
      end
    end
  end

  describe 'preview mode' do
    it 'does not persist changes' do
      collection_object = FactoryBot.create(:valid_collection_object, project: source_project)

      result = target_project.unify(source_project, preview: true, user_id: user.id)

      expect(result[:preview_mode]).to be true
      expect(result[:rollback_performed]).to be true

      collection_object.reload
      expect(collection_object.project_id).to eq(source_project.id)
    end

    it 'reports what would happen' do
      10.times { FactoryBot.create(:valid_collection_object, project: source_project) }

      result = target_project.unify(source_project, preview: true, user_id: user.id)

      expect(result[:statistics][:records_migrated]).to be >= 10
      expect(result[:rollback_performed]).to be true
    end
  end

  describe 'error handling and validation' do
    it 'rejects unifying project with itself' do
      expect {
        target_project.unify(target_project, preview: true, user_id: user.id)
      }.to raise_error(ArgumentError, /Cannot unify a project with itself/)
    end
  end

  describe 'cached field handling' do
    let!(:genus) do
      FactoryBot.create(
        :relationship_genus,
        name: 'Cachedgenus',
        parent: source_project.root_taxon_name,
        project: source_project
      )
    end

    context 'with skip_cached_rebuild: true' do
      it 'completes migration faster' do
        result = target_project.unify(source_project, preview: false, user_id: user.id, skip_cached_rebuild: true)

        expect(result[:unified]).to be true
        expect(result[:cached_rebuild]).to be_nil
      end
    end

    context 'with skip_cached_rebuild: false' do
      it 'rebuilds cached fields' do
        result = target_project.unify(source_project, preview: false, user_id: user.id, skip_cached_rebuild: false)

        expect(result[:cached_rebuild]).to be_present
        expect(result[:cached_rebuild][:models_rebuilt]).to be > 0
      end
    end
  end

  describe 'performance with multiple models' do
    it 'processes all models in MANIFEST order' do
      5.times { FactoryBot.create(:valid_collection_object, project: source_project) }
      3.times { FactoryBot.create(:valid_otu, project: source_project) }

      result = target_project.unify(source_project, preview: false, user_id: user.id)

      expect(result[:statistics][:models_processed]).to be > 1
    end

    it 'tracks processing by track type' do
      5.times { FactoryBot.create(:valid_collection_object, project: source_project) }

      result = target_project.unify(source_project, preview: false, user_id: user.id)

      stats = result[:statistics]
      # Check that at least one track was used (keys are dynamic based on what was processed)
      track_counts = stats.select { |k, v| k.to_s.end_with?('_track_count') }.values
      expect(track_counts.sum).to be > 0
    end
  end

  describe 'edge cases' do
    it 'handles empty source project' do
      empty_project = FactoryBot.create(:valid_project)

      result = target_project.unify(empty_project, preview: false, user_id: user.id)

      expect(result[:unified]).to be true
      expect(result[:statistics][:records_migrated]).to eq(0) # Empty project has no data to migrate (root is not moved)
    end

    it 'preserves community data (Sources not duplicated)' do
      source = FactoryBot.create(:valid_source)
      ps = FactoryBot.create(:project_source, project: source_project, source: source)

      initial_source_count = Source.count

      result = target_project.unify(source_project, preview: false, user_id: user.id)

      # Source should not be duplicated
      expect(Source.count).to eq(initial_source_count)

      # ProjectSource should be migrated
      ps.reload
      expect(ps.project_id).to eq(target_project.id)
    end

    it 'tracks duration in results' do
      result = target_project.unify(source_project, preview: true, user_id: user.id)

      expect(result[:duration_seconds]).to be > 0
      expect(result[:started_at]).to be_present
      expect(result[:completed_at]).to be_present
    end
  end

  describe 'multi-tenant isolation' do
    let!(:third_project) { FactoryBot.create(:valid_project, name: 'Third Project') }
    let!(:third_root) { third_project.root_taxon_name }

    context 'with data in three separate projects' do
      let!(:source_collection_objects) do
        3.times.map { FactoryBot.create(:valid_collection_object, project: source_project) }
      end

      let!(:target_collection_objects) do
        2.times.map { FactoryBot.create(:valid_collection_object, project: target_project) }
      end

      let!(:third_collection_objects) do
        5.times.map { FactoryBot.create(:valid_collection_object, project: third_project) }
      end

      let!(:source_genus) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Sourcegenus',
          parent: source_project.root_taxon_name,
          project: source_project
        )
      end

      let!(:third_genus) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Thirdgenus',
          parent: third_root,
          project: third_project
        )
      end

      it 'does not delete data from third project' do
        # Record third project data before merge
        third_co_ids = third_collection_objects.map(&:id)
        third_genus_id = third_genus.id

        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # All third project collection objects should still exist
        expect(CollectionObject.where(id: third_co_ids).count).to eq(5)

        # Third project genus should still exist
        expect(TaxonName.exists?(third_genus_id)).to be true
      end

      it 'does not change project_id of third project data' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # All third project data should still belong to third project
        third_collection_objects.each do |co|
          co.reload
          expect(co.project_id).to eq(third_project.id)
        end

        third_genus.reload
        expect(third_genus.project_id).to eq(third_project.id)
        expect(third_genus.parent).to eq(third_root)
      end

      it 'does not modify cached fields in third project' do
        # Get initial cached values
        third_genus.reload
        initial_cached_html = third_genus.cached_html
        initial_cached = third_genus.cached

        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Cached values should remain unchanged
        third_genus.reload
        expect(third_genus.cached_html).to eq(initial_cached_html)
        expect(third_genus.cached).to eq(initial_cached)
      end

      it 'maintains correct counts for all three projects' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Source project should be empty (except root)
        expect(CollectionObject.where(project_id: source_project.id).count).to eq(0)
        expect(TaxonName.where(project_id: source_project.id).where.not(parent_id: nil).count).to eq(0)

        # Target project should have source + original data
        expect(CollectionObject.where(project_id: target_project.id).count).to eq(5) # 3 from source + 2 original

        # Third project should be unchanged
        expect(CollectionObject.where(project_id: third_project.id).count).to eq(5)
        expect(TaxonName.where(project_id: third_project.id).where.not(parent_id: nil).count).to eq(1) # just the genus
      end
    end

    context 'with related data across projects' do
      let!(:shared_source) { FactoryBot.create(:valid_source) }

      let!(:source_ps) do
        FactoryBot.create(:project_source, project: source_project, source: shared_source)
      end

      let!(:third_ps) do
        FactoryBot.create(:project_source, project: third_project, source: shared_source)
      end

      it 'does not affect third project relationships to community data' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Third project's relationship to shared source should be unchanged
        third_ps.reload
        expect(third_ps.project_id).to eq(third_project.id)
        expect(third_ps.source_id).to eq(shared_source.id)

        # Source's relationship should now belong to target
        source_ps.reload
        expect(source_ps.project_id).to eq(target_project.id)
      end
    end
  end

  describe 'annotation models optimization' do
    context 'with annotation data' do
      let!(:source_otu) do
        FactoryBot.create(:valid_otu, project: source_project)
      end

      let!(:source_note) do
        FactoryBot.create(:note, note_object: source_otu, project: source_project, text: 'Test note')
      end

      let!(:keyword) { FactoryBot.create(:valid_keyword, project: source_project) }
      let!(:source_tag) do
        Tag.create!(tag_object: source_otu, keyword: keyword, project_id: source_project.id)
      end

      it 'migrates annotations with fast track SQL' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Annotations should be migrated
        source_note.reload
        source_tag.reload

        expect(source_note.project_id).to eq(target_project.id)
        expect(source_tag.project_id).to eq(target_project.id)
      end

      it 'uses fast track for annotation models' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        # Should show fast_track_count > 0 due to annotations
        expect(result[:statistics][:fast_track_count]).to be > 0
      end
    end
  end

  describe 'Image deduplication' do
    # valid_image always uploads the same tiny.png file, so fingerprints match.
    # Uniqueness is scoped to project_id, so two projects may each hold it.
    let!(:source_image) { FactoryBot.create(:valid_image, project_id: source_project.id) }
    let!(:target_image) { FactoryBot.create(:valid_image, project_id: target_project.id) }
    let!(:source_otu)   { FactoryBot.create(:valid_otu, project: source_project) }

    context 'when a source image has a Depiction and a matching fingerprint in target' do
      let!(:depiction) do
        Depiction.create!(
          image: source_image,
          depiction_object: source_otu,
          project_id: source_project.id
        )
      end

      it 'reroutes the Depiction to the target image' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        depiction.reload
        expect(depiction.image_id).to eq(target_image.id)
      end

      it 'destroys the duplicate source image' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        expect(Image.exists?(source_image.id)).to be false
      end

      it 'does not orphan the Depiction' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        depiction.reload
        expect(depiction.image).to eq(target_image)
      end

      it 'reports the detected duplicate in results' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        image_result = result[:details_by_model]['Image']
        expect(image_result[:duplicates_found].length).to eq(1)
      end
    end

    context 'when both source and target already depict the same object with matching images' do
      let!(:target_otu) { FactoryBot.create(:valid_otu, project: target_project) }

      let!(:source_depiction) do
        Depiction.create!(
          image: source_image,
          depiction_object: source_otu,
          project_id: source_project.id
        )
      end

      let!(:target_depiction) do
        # Intentionally cross-project: same depiction_object_id in target triggers
        # the duplicate-detection path in reroute_depictions. Use validate: false
        # since the FK validation would otherwise reject source_otu in target_project.
        d = Depiction.new(image: target_image, depiction_object: source_otu,
                          project_id: target_project.id, by: user)
        d.save!(validate: false)
        d
      end

      it 'destroys the redundant source Depiction rather than creating a duplicate' do
        expect {
          target_project.unify(source_project, preview: false, user_id: user.id)
        }.to change { Depiction.count }.by(-1)

        expect(Depiction.exists?(source_depiction.id)).to be false
        expect(Depiction.exists?(target_depiction.id)).to be true
      end

      it 'destroys the source image' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(Image.exists?(source_image.id)).to be false
      end
    end

    context 'when a source image has no Depictions and a matching fingerprint in target' do
      it 'destroys the source image without error' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(Image.exists?(source_image.id)).to be false
        expect(result[:errors]).to be_empty
      end
    end
  end

  describe 'Document deduplication' do
    let!(:source_document) { FactoryBot.create(:valid_document, project_id: source_project.id) }
    let!(:target_document) { FactoryBot.create(:valid_document, project_id: target_project.id) }
    let!(:source_otu)      { FactoryBot.create(:valid_otu, project: source_project) }

    before do
      # Force matching fingerprints so the handler treats them as duplicates
      target_document.update_column(:document_file_fingerprint, source_document.document_file_fingerprint)
    end

    context 'when a source document has a Documentation and a matching fingerprint in target' do
      let!(:documentation) do
        Documentation.create!(
          document: source_document,
          documentation_object: source_otu,
          project_id: source_project.id
        )
      end

      it 're-routes the Documentation to the target document' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        documentation.reload
        expect(documentation.document_id).to eq(target_document.id)
      end

      it 'destroys the duplicate source document' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        expect(Document.exists?(source_document.id)).to be false
      end

      it 'does not orphan the Documentation' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        documentation.reload
        expect(documentation.document).to eq(target_document)
      end

      it 'reports the detected duplicate in results' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        doc_result = result[:details_by_model]['Document']
        expect(doc_result[:duplicates_found].length).to eq(1)
      end
    end

    context 'when a source document has no Documentation and a matching fingerprint in target' do
      it 'destroys the source document without error' do
        target_project.unify(source_project, preview: false, user_id: user.id)

        expect(Document.exists?(source_document.id)).to be false
        expect(target_project.unify(source_project, preview: false, user_id: user.id)[:errors]).to be_empty
      end
    end
  end

  describe 'Image annotation rerouting' do
    # When a source Image is a fingerprint-duplicate, Phase 2 cleanup_sentinel
    # re-routes all annotations to the target Image before destroying the sentinel.
    let!(:source_image) { FactoryBot.create(:valid_image, project_id: source_project.id) }
    let!(:target_image) { FactoryBot.create(:valid_image, project_id: target_project.id) }

    context 'when source image has a Tag' do
      let!(:keyword) { FactoryBot.create(:valid_keyword, project: source_project) }
      let!(:tag) do
        Tag.create!(tag_object: source_image, keyword: keyword, project_id: source_project.id)
      end

      it 'reroutes the Tag to the target image' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        tag.reload
        expect(tag.tag_object).to eq(target_image)
      end

      it 'does not destroy the Tag' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(Tag.where(id: tag.id).exists?).to be true
      end
    end

    context 'when source image has a Note' do
      let!(:note) do
        Note.create!(note_object: source_image, text: 'test note', project_id: source_project.id)
      end

      it 'reroutes the Note to the target image' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        note.reload
        expect(note.note_object).to eq(target_image)
      end
    end

    context 'when source image has a Citation with no match on target' do
      let!(:source) { FactoryBot.create(:valid_source_bibtex) }
      let!(:citation) do
        Citation.create!(citation_object: source_image, source: source, project_id: source_project.id)
      end

      it 'reroutes the Citation to the target image' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        citation.reload
        expect(citation.citation_object).to eq(target_image)
      end
    end

    context 'when source and target images have Citations from the same Source' do
      # Sources are shared cross-project, so duplicate Citations can exist.
      # AnnotationRerouter must move CitationTopics to the surviving Citation
      # before destroying the source duplicate.
      let!(:shared_source) { FactoryBot.create(:valid_source_bibtex) }
      let!(:source_citation) do
        Citation.create!(citation_object: source_image, source: shared_source, project_id: source_project.id)
      end
      let!(:target_citation) do
        Citation.create!(citation_object: target_image, source: shared_source, project_id: target_project.id)
      end
      let!(:topic) { FactoryBot.create(:valid_topic, project: source_project) }
      let!(:citation_topic) do
        CitationTopic.create!(citation: source_citation, topic: topic, project_id: source_project.id)
      end

      it 'reroutes the CitationTopic to the surviving target Citation' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        citation_topic.reload
        expect(citation_topic.citation).to eq(target_citation)
      end

      it 'destroys the duplicate source Citation' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(Citation.exists?(source_citation.id)).to be false
      end
    end

    it 'destroys the source image' do
      target_project.unify(source_project, preview: false, user_id: user.id)
      expect(Image.exists?(source_image.id)).to be false
    end
  end

  describe 'Document annotation rerouting' do
    let!(:source_document) { FactoryBot.create(:valid_document, project_id: source_project.id) }
    let!(:target_document) { FactoryBot.create(:valid_document, project_id: target_project.id) }
    let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }

    before do
      target_document.update_column(:document_file_fingerprint, source_document.document_file_fingerprint)
    end

    context 'when source document has a Tag' do
      let!(:keyword) { FactoryBot.create(:valid_keyword, project: source_project) }
      let!(:tag) do
        Tag.create!(tag_object: source_document, keyword: keyword, project_id: source_project.id)
      end

      it 'reroutes the Tag to the target document' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        tag.reload
        expect(tag.tag_object).to eq(target_document)
      end
    end

    context 'when source document has a Note' do
      let!(:note) do
        Note.create!(note_object: source_document, text: 'test note', project_id: source_project.id)
      end

      it 'reroutes the Note to the target document' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        note.reload
        expect(note.note_object).to eq(target_document)
      end
    end

    it 'destroys the source document' do
      target_project.unify(source_project, preview: false, user_id: user.id)
      expect(Document.exists?(source_document.id)).to be false
    end
  end

  describe 'TaxonDetermination position conflict handling' do
    # acts_as_list resets position to 1 on project_id scope change, causing
    # false uniqueness conflicts when multiple TDs on the same CO are migrated.
    # There are no real cross-project position conflicts (COs are project-specific).
    # handle_unify_conflict restores each TD's original position, bumping any
    # earlier-processed sibling that stole the slot.
    let!(:co)   { FactoryBot.create(:valid_collection_object, project: source_project) }
    let!(:otu1) { FactoryBot.create(:valid_otu, project: source_project) }
    let!(:otu2) { FactoryBot.create(:valid_otu, project: source_project) }

    # acts_as_list add_new_at: :top → td2 (created second) gets position 1
    let!(:td1) { TaxonDetermination.create!(taxon_determination_object: co, otu: otu1, project: source_project) }
    let!(:td2) { TaxonDetermination.create!(taxon_determination_object: co, otu: otu2, project: source_project) }

    it 'migrates both TDs without conflicts' do
      result = target_project.unify(source_project, preview: false, user_id: user.id)
      expect(result[:conflicts]).to be_empty
      expect(result[:errors]).to be_empty
    end

    it 'migrates both TDs to the target project' do
      target_project.unify(source_project, preview: false, user_id: user.id)
      expect(td1.reload.project_id).to eq(target_project.id)
      expect(td2.reload.project_id).to eq(target_project.id)
    end

    it 'assigns distinct positions in the target project' do
      target_project.unify(source_project, preview: false, user_id: user.id)
      positions = [td1.reload.position, td2.reload.position]
      expect(positions.uniq.length).to eq(2)
    end

    it 'preserves the accepted determination (original position 1) at position 1' do
      # td2 was created last, so acts_as_list placed it at position 1 (accepted)
      expect(td2.position).to eq(1)
      target_project.unify(source_project, preview: false, user_id: user.id)
      expect(td2.reload.position).to eq(1)
    end
  end

  describe 'ControlledVocabularyTerm conflict handling' do
    # When source and target projects have a CVT with the same name+type (or same
    # definition), handle_unify_conflict reroutes all FK references to the target
    # CVT and destroys the source, avoiding the conflict without leaving orphaned data.

    shared_examples 'a merged CVT' do |type_name|
      it 'reports no conflicts' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:conflicts].map { |c| c[:model] }).not_to include('ControlledVocabularyTerm')
      end

      it 'destroys the source CVT' do
        source_id = source_cvt.id
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(ControlledVocabularyTerm.exists?(source_id)).to be false
      end

      it 'keeps the target CVT' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(ControlledVocabularyTerm.exists?(target_cvt.id)).to be true
      end
    end

    context 'Keyword with Tags' do
      let!(:source_cvt) { FactoryBot.create(:valid_keyword, name: 'Shared', definition: 'A' * 20, project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_keyword, name: 'Shared', definition: 'A' * 20, project: target_project) }
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:tag)        { Tag.create!(tag_object: source_otu, keyword: source_cvt, project_id: source_project.id) }

      include_examples 'a merged CVT', 'Keyword'

      it 'reroutes the Tag to the target Keyword' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(tag.reload.keyword_id).to eq(target_cvt.id)
      end
    end

    context 'Topic with CitationTopics' do
      let!(:source_cvt) { FactoryBot.create(:valid_topic, name: 'Shared', definition: 'A' * 20, project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_topic, name: 'Shared', definition: 'A' * 20, project: target_project) }
      let!(:source)     { FactoryBot.create(:valid_source_bibtex) }
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:citation)   { Citation.create!(citation_object: source_otu, source: source, project_id: source_project.id) }
      let!(:citation_topic) { CitationTopic.create!(citation: citation, topic: source_cvt, project_id: source_project.id) }

      include_examples 'a merged CVT', 'Topic'

      it 'reroutes the CitationTopic to the target Topic' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(citation_topic.reload.topic_id).to eq(target_cvt.id)
      end
    end

    context 'BiocurationClass with BiocurationClassifications' do
      let!(:source_cvt) { FactoryBot.create(:valid_biocuration_class, name: 'Shared', definition: 'A' * 20, project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_biocuration_class, name: 'Shared', definition: 'A' * 20, project: target_project) }
      let!(:co)         { FactoryBot.create(:valid_collection_object, project: source_project) }
      let!(:bc)         { BiocurationClassification.create!(biocuration_class: source_cvt, biocuration_classification_object: co, project_id: source_project.id) }

      include_examples 'a merged CVT', 'BiocurationClass'

      it 'reroutes the BiocurationClassification to the target BiocurationClass' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(bc.reload.biocuration_class_id).to eq(target_cvt.id)
      end
    end

    context 'Predicate with DataAttributes' do
      let!(:source_cvt)  { FactoryBot.create(:valid_predicate, name: 'Shared', definition: 'A' * 20, project: source_project) }
      let!(:target_cvt)  { FactoryBot.create(:valid_predicate, name: 'Shared', definition: 'A' * 20, project: target_project) }
      let!(:source_otu)  { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:data_attr)   { InternalAttribute.create!(attribute_subject: source_otu, predicate: source_cvt, value: 'test', project_id: source_project.id) }

      include_examples 'a merged CVT', 'Predicate'

      it 'reroutes the DataAttribute to the target Predicate' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(data_attr.reload.controlled_vocabulary_term_id).to eq(target_cvt.id)
      end
    end

    context 'ConfidenceLevel with Confidences' do
      let!(:source_cvt) { FactoryBot.create(:valid_confidence_level, name: 'Shared', definition: 'A' * 20, project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_confidence_level, name: 'Shared', definition: 'A' * 20, project: target_project) }
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:confidence) { Confidence.create!(confidence_object: source_otu, confidence_level: source_cvt, project_id: source_project.id) }

      include_examples 'a merged CVT', 'ConfidenceLevel'

      it 'reroutes the Confidence to the target ConfidenceLevel' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(confidence.reload.confidence_level_id).to eq(target_cvt.id)
      end
    end

    # The existing contexts above (name: 'Shared', definition: 'A' * 20 for both) already
    # exercise the name+definition multi-field conflict path through the sentinel loop.
    # The contexts below cover single-field and mixed-field conflict combinations to verify
    # that only failing fields are stamped.

    context 'definition-only conflict (different names, same definition) — not equivalent' do
      # Names differ: not semantically equivalent. The unify must fail so the
      # user can resolve the definition clash manually before retrying.
      let!(:source_cvt) { FactoryBot.create(:valid_keyword, name: 'Source Keyword', definition: 'A shared definition here', project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_keyword, name: 'Target Keyword', definition: 'A shared definition here', project: target_project) }
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:tag)        { Tag.create!(tag_object: source_otu, keyword: source_cvt, project_id: source_project.id) }

      it 'reports a CVT conflict' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:conflicts].map { |c| c[:model] }).to include('ControlledVocabularyTerm')
      end

      it 'does not unify' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:unified]).to be false
      end

      it 'preserves the source CVT (transaction rolled back)' do
        source_id = source_cvt.id
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(ControlledVocabularyTerm.exists?(source_id)).to be true
        expect(source_cvt.reload.project_id).to eq(source_project.id)
      end

      it 'does not touch the tag' do
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(tag.reload.keyword_id).to eq(source_cvt.id)
      end
    end

    context 'URI-only conflict (same URI+uri_relation, different name and definition) — not equivalent' do
      # Both name and definition differ: not semantically equivalent.
      let(:shared_uri) { 'http://purl.obolibrary.org/obo/RO_0000001' }
      let!(:source_cvt) { FactoryBot.create(:valid_keyword, name: 'Source Keyword', definition: 'Source keyword definition text', uri: shared_uri, uri_relation: 'skos:exactMatch', project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_keyword, name: 'Target Keyword', definition: 'Target keyword definition text', uri: shared_uri, uri_relation: 'skos:exactMatch', project: target_project) }
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:tag)        { Tag.create!(tag_object: source_otu, keyword: source_cvt, project_id: source_project.id) }

      it 'reports a CVT conflict' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:conflicts].map { |c| c[:model] }).to include('ControlledVocabularyTerm')
      end

      it 'does not unify' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:unified]).to be false
      end

      it 'preserves the source CVT (transaction rolled back)' do
        source_id = source_cvt.id
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(ControlledVocabularyTerm.exists?(source_id)).to be true
        expect(source_cvt.reload.project_id).to eq(source_project.id)
      end
    end

    context 'name and URI both conflict (definition differs) — not equivalent' do
      # Definitions differ: not semantically equivalent even though name+URI match.
      let(:shared_uri) { 'http://purl.obolibrary.org/obo/RO_0000001' }
      let!(:source_cvt) { FactoryBot.create(:valid_keyword, name: 'Shared', definition: 'Source keyword definition text', uri: shared_uri, uri_relation: 'skos:exactMatch', project: source_project) }
      let!(:target_cvt) { FactoryBot.create(:valid_keyword, name: 'Shared', definition: 'Target keyword definition text', uri: shared_uri, uri_relation: 'skos:exactMatch', project: target_project) }
      let!(:source_otu) { FactoryBot.create(:valid_otu, project: source_project) }
      let!(:tag)        { Tag.create!(tag_object: source_otu, keyword: source_cvt, project_id: source_project.id) }

      it 'reports a CVT conflict' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:conflicts].map { |c| c[:model] }).to include('ControlledVocabularyTerm')
      end

      it 'does not unify' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:unified]).to be false
      end

      it 'preserves the source CVT (transaction rolled back)' do
        source_id = source_cvt.id
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(ControlledVocabularyTerm.exists?(source_id)).to be true
        expect(source_cvt.reload.project_id).to eq(source_project.id)
      end
    end

    context 'name and definition conflict with different target CVTs (multi-target)' do
      # source_cvt.name matches target_a, source_cvt.definition matches target_b.
      # find_conflicting_target_cvts returns two distinct targets so sole_target is
      # nil and auto-resolution must not proceed.
      let!(:source_cvt) do
        FactoryBot.create(:valid_keyword,
          name: 'Shared Name',
          definition: 'Shared definition text here',
          project: source_project)
      end
      let!(:target_a) do
        FactoryBot.create(:valid_keyword,
          name: 'Shared Name',
          definition: 'Target A only definition text',
          project: target_project)
      end
      let!(:target_b) do
        FactoryBot.create(:valid_keyword,
          name: 'Target B name only',
          definition: 'Shared definition text here',
          project: target_project)
      end

      it 'reports a CVT conflict' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:conflicts].map { |c| c[:model] }).to include('ControlledVocabularyTerm')
      end

      it 'does not unify' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        expect(result[:unified]).to be false
      end

      it 'reports the conflicting target CVT for each field' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)
        cvt_conflict = result[:conflicts].find { |c| c[:model] == 'ControlledVocabularyTerm' }
        expect(cvt_conflict[:target_cvts][:name][:id]).to eq(target_a.id)
        expect(cvt_conflict[:target_cvts][:definition][:id]).to eq(target_b.id)
      end

      it 'preserves the source CVT (transaction rolled back)' do
        source_id = source_cvt.id
        target_project.unify(source_project, preview: false, user_id: user.id)
        expect(ControlledVocabularyTerm.exists?(source_id)).to be true
        expect(source_cvt.reload.project_id).to eq(source_project.id)
      end
    end

    context 'on_model_migrated progress callback' do
      let!(:source_cvt) { FactoryBot.create(:valid_keyword, project: source_project) }

      it 'fires for ControlledVocabularyTerm' do
        fired = []
        target_project.unify(source_project, preview: false, user_id: user.id,
          on_model_migrated: ->(model, _track, _result) { fired << model })
        expect(fired).to include('ControlledVocabularyTerm')
      end
    end
  end

  describe 'cleanup after merge' do
    context 'after successful merge' do
      let!(:source_otu) do
        FactoryBot.create(:valid_otu, project: source_project)
      end

      let!(:source_taxon_name) do
        FactoryBot.create(
          :relationship_genus,
          name: 'Testgenus',
          parent: source_project.root_taxon_name,
          project: source_project
        )
      end

      let!(:source_collection_object) do
        FactoryBot.create(:valid_collection_object, project: source_project)
      end

      it 'allows nuke() to succeed on emptied project_to_remove' do
        # Perform actual merge (not preview)
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Verify data was migrated
        source_otu.reload
        source_taxon_name.reload
        source_collection_object.reload

        expect(source_otu.project_id).to eq(target_project.id)
        expect(source_taxon_name.project_id).to eq(target_project.id)
        expect(source_collection_object.project_id).to eq(target_project.id)

        # Nuke should not raise errors on the emptied source project
        # Note: itself won't succeed due to dependent: :restrict_with_error
        # on project_members and project_sources, but all data should be removed
        expect {
          source_project.send(:nuke)
        }.not_to raise_error
      end

      it 'leaves only root TaxonName in project_to_remove after merge' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Only the root should remain in source project
        remaining_taxon_names = TaxonName.where(project_id: source_project.id)
        expect(remaining_taxon_names.count).to eq(1)
        expect(remaining_taxon_names.first.parent_id).to be_nil # It's the root
      end

      it 'removes all data except root from project_to_remove' do
        result = target_project.unify(source_project, preview: false, user_id: user.id)

        expect(result[:unified]).to be true

        # Check various models are empty in source project
        expect(Otu.where(project_id: source_project.id).count).to eq(0)
        expect(CollectionObject.where(project_id: source_project.id).count).to eq(0)
        expect(TaxonName.where(project_id: source_project.id).where.not(parent_id: nil).count).to eq(0)
      end
    end
  end
end
