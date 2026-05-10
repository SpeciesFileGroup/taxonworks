# Shared annotation rerouter for project unification special handlers.
#
# When a source object (Image, Document) is a fingerprint-duplicate of an
# existing target object it must be destroyed. Before destruction, all
# annotations attached to the source must be moved to the target so no
# data is lost.
#
# Simple annotation types (Tag, Note, DataAttribute, etc.) are leaf nodes
# with no associated data of their own. For these we update the polymorphic
# FK directly; a RecordNotUnique exception means the target already carries
# an identical annotation, so we destroy the source copy instead.
#
# Citation is the exception: Sources are shared cross-project data, so a
# Citation on source and target may reference the same Source — a genuine
# duplicate. But Citations have CitationTopics that must be preserved.
# For duplicate Citations we reroute CitationTopics to the surviving target
# Citation first (CitationTopic ids reference CVTs, which are independent
# per project, so they never create uniqueness conflicts on the target),
# then destroy the source Citation.
#
# Ordering assumption: this module runs inside a special-track handler
# (ImageHandler, DocumentHandler) which is processed before most annotation
# models in MANIFEST.reverse order.  See
# spec/lib/project_unification/manifest_ordering_spec.rb.
#
module ProjectUnification
  module AnnotationRerouter
    # Annotation types for Image: Note, Tag, Identifier, Attribution (has_one),
    #   ProtocolRelationship, plus Citation (handled separately below).
    # Annotation types for Document: Note, Tag, Identifier.
    # If either model gains a new annotation concern, add it here and update
    # spec/lib/project_unification/annotation_rerouter_spec.rb.
    SIMPLE_ANNOTATION_CONFIGS = [
      { klass: 'Tag',                  id_col: :tag_object_id,                        type_col: :tag_object_type },
      { klass: 'Note',                 id_col: :note_object_id,                       type_col: :note_object_type },
      { klass: 'Attribution',          id_col: :attribution_object_id,                type_col: :attribution_object_type },
      { klass: 'Identifier',           id_col: :identifier_object_id,                 type_col: :identifier_object_type },
      { klass: 'ProtocolRelationship', id_col: :protocol_relationship_object_id,      type_col: :protocol_relationship_object_type },
    ].freeze

    # Move all annotations from source_object to target (identified by target_id).
    # Must be called before source_object is destroyed.
    def reroute_annotations(source_object, target_id)
      object_type = source_object.class.name
      source_id   = source_object.id

      SIMPLE_ANNOTATION_CONFIGS.each do |config|
        reroute_simple_annotation(
          config[:klass].constantize,
          config[:id_col],
          config[:type_col],
          source_id,
          target_id,
          object_type
        )
      end

      reroute_citations(source_id, target_id, object_type)
    end

    private

    def reroute_simple_annotation(klass, id_col, type_col, source_id, target_id, object_type)
      klass.where(id_col => source_id, type_col => object_type).find_each do |annotation|
        annotation.update_column(id_col, target_id)
      rescue ActiveRecord::RecordNotUnique
        annotation.destroy
      end
    end

    def reroute_citations(source_object_id, target_object_id, object_type)
      Citation.where(
        citation_object_id: source_object_id,
        citation_object_type: object_type
      ).find_each do |citation|
        target_citation = Citation.find_by(
          citation_object_id: target_object_id,
          citation_object_type: object_type,
          source_id: citation.source_id,
          pages: citation.pages
        )

        if target_citation
          citation.citation_topics.update_all(citation_id: target_citation.id)
          citation.destroy
        else
          citation.update_column(:citation_object_id, target_object_id)
        end
      end
    end
  end
end
