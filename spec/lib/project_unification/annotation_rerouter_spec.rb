require 'rails_helper'

RSpec.describe ProjectUnification::AnnotationRerouter do
  # SIMPLE_ANNOTATION_CONFIGS is the contract for what gets rerouted off source
  # objects (Image, Document) before they are destroyed during fingerprint-based
  # deduplication.  If Image or Document gains a new annotation concern — or if
  # a new model is passed to reroute_annotations — a developer must consciously
  # decide:
  #
  #   a) Fast-path (leaf annotation, no sub-data): add an entry to
  #      SIMPLE_ANNOTATION_CONFIGS.
  #   b) Needs sub-data rerouting (like Citation → CitationTopic): add a
  #      dedicated private method in AnnotationRerouter and call it from
  #      reroute_annotations.
  #
  # These specs will fail when the annotation set on Image or Document changes,
  # forcing that decision.

  let(:config_classes) do
    described_class::SIMPLE_ANNOTATION_CONFIGS.map { |c| c[:klass] }.sort
  end

  # Returns the names of has_many + has_one annotation-model associations on klass.
  def annotation_association_classes(klass, candidates)
    all_reflections = klass.reflect_on_all_associations(:has_many) +
                      klass.reflect_on_all_associations(:has_one)
    all_reflections.filter_map { |r| r.klass.name rescue nil }
                   .intersection(candidates)
  end

  describe 'SIMPLE_ANNOTATION_CONFIGS' do
    # The known annotation model names across TaxonWorks. Update this list when
    # new polymorphic annotation models are introduced to the application.
    let(:all_known_annotation_models) do
      %w[Tag Note Citation DataAttribute AlternateValue Confidence Attribution
         Identifier Conveyance ProtocolRelationship]
    end

    it 'contains exactly the non-Citation annotations carried by Image' do
      image_annotations = annotation_association_classes(Image, all_known_annotation_models) - ['Citation']
      expect(config_classes).to match_array(image_annotations),
        "SIMPLE_ANNOTATION_CONFIGS must match Image's annotation types (excluding Citation). " \
        "Got #{config_classes}, expected #{image_annotations.sort}"
    end

    it 'covers all annotations carried by Document (Document has no Citations)' do
      document_annotations = annotation_association_classes(Document, all_known_annotation_models)
      expect(config_classes).to include(*document_annotations),
        "SIMPLE_ANNOTATION_CONFIGS must include all Document annotation types. " \
        "Missing: #{document_annotations - config_classes}"
    end

    it 'has the correct polymorphic column names for each entry' do
      described_class::SIMPLE_ANNOTATION_CONFIGS.each do |config|
        klass = config[:klass].constantize
        expect(klass.column_names).to include(config[:id_col].to_s),
          "#{config[:klass]} does not have column #{config[:id_col]}"
        expect(klass.column_names).to include(config[:type_col].to_s),
          "#{config[:klass]} does not have column #{config[:type_col]}"
      end
    end
  end
end
