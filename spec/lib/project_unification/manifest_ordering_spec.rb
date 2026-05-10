require 'rails_helper'

# Guards ordering assumptions that project unification relies on.
#
# Project::MANIFEST is deletion order (child first, parent last).
# Migration processes MANIFEST.reverse, so higher MANIFEST index = migrated first.
#
# ImageHandler and DocumentHandler (special track) reroute annotations off
# source objects before destroying them. At that point annotations are still
# project_id=source; the fast-track updates their project_id afterward.
# This two-phase approach requires:
#
#   1. The annotated model (Image, Document) to have a higher MANIFEST index
#      than every annotation model it can carry, so special handlers run first.
#   2. ControlledVocabularyTerm to have an even higher index, so CVTs are
#      already in the target project when Tags (which reference CVTs by id)
#      are rerouted.
#   3. Document to have a higher index than Documentation, so DocumentHandler
#      reroutes Documentation.document_id before the fast-track touches it.
#
# If any of these assertions fail, the corresponding migration step will
# silently produce orphaned or stale records.

RSpec.describe 'Project::MANIFEST ordering for project unification', type: :model do
  def manifest_index(model_name)
    index = Project::MANIFEST.index(model_name)
    raise ArgumentError, "#{model_name} not found in Project::MANIFEST" if index.nil?
    index
  end

  # True when `first` is processed before `second` during migration.
  def migrated_before?(first, second)
    manifest_index(first) > manifest_index(second)
  end

  describe 'Image special handler' do
    it 'ControlledVocabularyTerm is migrated before Image' do
      # Tags reference Keywords (CVT subclass) by id. CVTs must be in the
      # target project before tags are rerouted off destroyed source images.
      expect(migrated_before?('ControlledVocabularyTerm', 'Image')).to be true
    end

    it 'Image is migrated before Depiction' do
      # reroute_depictions runs inside ImageHandler; Depictions must still
      # carry project_id=source at that point.
      expect(migrated_before?('Image', 'Depiction')).to be true
    end

    # AnnotationRerouter moves these off a source Image before it is destroyed.
    # Each must still be project_id=source when ImageHandler runs.
    %w[Tag Note Citation CitationTopic DataAttribute AlternateValue
       Confidence Attribution Identifier Conveyance].each do |annotation|
      it "Image is migrated before #{annotation}" do
        expect(migrated_before?('Image', annotation)).to be true
      end
    end
  end

  describe 'Document special handler' do
    it 'ControlledVocabularyTerm is migrated before Document' do
      expect(migrated_before?('ControlledVocabularyTerm', 'Document')).to be true
    end

    it 'Document is migrated before Documentation' do
      # DocumentHandler reroutes Documentation.document_id; Documentation must
      # still be project_id=source so the fast-track can update it afterward.
      expect(migrated_before?('Document', 'Documentation')).to be true
    end

    # Identifier (MANIFEST index 43) is migrated before Document (index 23),
    # but DocumentHandler still reroutes Identifiers correctly because
    # reroute_annotations queries by identifier_object_id, not project_id.
    %w[Tag Note Citation CitationTopic DataAttribute AlternateValue
       Confidence Attribution].each do |annotation|
      it "Document is migrated before #{annotation}" do
        expect(migrated_before?('Document', annotation)).to be true
      end
    end
  end
end
