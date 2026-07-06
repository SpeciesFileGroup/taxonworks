require 'rails_helper'

describe 'Shared::Unify', type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }


  # Canary spec: Shared::Unify detects acts_as_list models via
  # respond_to?(:acts_as_list_options). If the acts_as_list gem removes or
  # renames that method the position re-sort in unify will silently stop
  # working. This spec ensures the detection is checking live gem code.
  specify 'acts_as_list exposes acts_as_list_options on list models' do
    expect(Georeference).to respond_to(:acts_as_list_options)
  end

  specify 'unifies Topics' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)

    t1.unify(t2)
    expect(t2.destroyed?).to be_truthy
  end

  specify 'unifies Topics with identical Content' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)

    s =  'Exactly the same'

    c1 = FactoryBot.create(:valid_content, topic: t1, text: s)
    c2 = FactoryBot.create(:valid_content, topic: t2, text: s, otu: c1.otu)

    t1.unify(t2)

    expect(t2.destroyed?).to be_truthy
    expect(Content.all.reload.count).to eq(1)
  end

  specify 'unifies Topics with identical Citations' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)

    c1 = FactoryBot.create(:valid_citation)

    c1.topics << t1
    c1.topics << t2

    t1.unify(t2)

    expect(t2.destroyed?).to be_truthy
    expect(Citation.first.topics.count).to eq(1)
  end

  specify 'unifies Otus with CommonNames' do
    c = FactoryBot.create(:valid_common_name, otu: o1)
    c1 = FactoryBot.create(:valid_common_name, otu: o2)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.common_names.reload.count).to eq(2)
  end

  specify 'unifies Otus in BiologicalAssociations ' do
    o3 = FactoryBot.create(:valid_otu)
    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: o3)

    expect(o1.related_biological_associations.reload.count).to eq(0)

    o1.unify(o3)

    expect(o3.destroyed?).to be_truthy
    expect(o1.related_biological_associations.reload.count).to eq(1)
  end

  specify 'unifies Otus in BiologicalAssociations - merge object associations' do
    [o1,o2] # so that numbers match ids
    o3 = FactoryBot.create(:valid_otu)

    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: o1)
    ba2 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2,
                            biological_association_object: o3, biological_relationship: ba1.biological_relationship)

    s = FactoryBot.create(:valid_source)
    c1  = FactoryBot.create(:valid_citation, citation_object: ba1)
    c2  = FactoryBot.create(:valid_citation, citation_object: ba2)

    o1.unify(o3)

    expect(o3.destroyed?).to be_truthy
    expect(BiologicalAssociation.find_by(id: ba2.id)).to be_falsey
    expect(o1.related_biological_associations.reload.count).to eq(1)
    expect(o1.biological_associations.reload.count).to eq(0)
    expect(ba1.reload.citations.count).to eq(2)
  end

  specify 'unifies Otus in BiologicalAssociations - merge subject associations' do
    [o1,o2] # so that numbers match ids
    o3 = FactoryBot.create(:valid_otu)

    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o1, biological_association_object: o2)
    ba2 = FactoryBot.create(:valid_biological_association, biological_association_subject: o3,
                            biological_association_object: o2, biological_relationship: ba1.biological_relationship)

    s = FactoryBot.create(:valid_source)
    c1  = FactoryBot.create(:valid_citation, citation_object: ba1)
    c2  = FactoryBot.create(:valid_citation, citation_object: ba2)

    u = o1.unify(o3)

    expect(o3.destroyed?).to be_truthy
    expect(BiologicalAssociation.find_by(id: ba2.id)).to be_falsey
    expect(o1.biological_associations.reload.count).to eq(1)
    expect(o1.related_biological_associations.reload.count).to eq(0)
    expect(ba1.reload.citations.count).to eq(2)
  end

  specify 'unifies Otus in Matrices with overlapping observations' do
    om = ObservationMatrix.create!(name: 'Lune')
    ri1 = ObservationMatrixRowItem::Single.create!(observation_object: o1, observation_matrix: om)
    ri2 = ObservationMatrixRowItem::Single.create!(observation_object: o2, observation_matrix: om)
    r1 = om.reload.observation_matrix_rows.first
    r2 = om.observation_matrix_rows.second

    # See comments below if re-implemented
    # cit2 = Citation.create!(citation_object: r2, source:)
    # tag = Tag.create!(tag_object: r2, keyword: FactoryBot.create(:valid_keyword))

    d = FactoryBot.create(:valid_descriptor)

    d1 = Descriptor::Qualitative.create!(name: 'foo')
    cs = CharacterState.create!(label: 0, name: 'foo', descriptor: d1)
    c1 = FactoryBot.create(:valid_observation_matrix_column, observation_matrix: om, descriptor: d1 )
    # Give both rows the same character state.
    Observation.code_column(c1.id, { character_state: cs })
    obs1 = o1.observations.first
    obs2 = o2.observations.first

    o1.unify(o2)
    expect(ObservationMatrixRowItem.find_by(id: ri2.id)).to be_falsey
    expect(ObservationMatrixRow.find_by(id: r2.id)).to be_falsey
    expect(Observation.find_by(id: obs2.id)).to be_falsey
    expect(Otu.find_by(id: o2.id)).to be_falsey

    expect(o1.reload.observation_matrix_row_items.map(&:id)).to eq([ri1.id])
    expect(o1.observation_matrix_rows.map(&:id)).to eq([r1.id])
    expect(o1.observations.map(&:id)).to eq([obs1.id])

    expect(om.reload.observation_matrix_row_items.map(&:id)).to eq([ri1.id])
    expect(o1.observation_matrix_rows.map(&:id)).to eq([r1.id])

    # See comments on ObservationMatrixRowItem if re-implementing these
    #
    # expect(r1.reload.tags.map(&:id)).to eq([tag.id])
    # # !! Fails, cit2 still points to r2.
    # expect(r1.reload.citations.map(&:id)).to eq([cit2.id])
  end

  specify 'ObservationMatrixRows with refcount > 1 aren\'t destroyed' do
    om = ObservationMatrix.create!(name: 'Lune')
    ri1 = ObservationMatrixRowItem::Single.create!(observation_object: o1, observation_matrix: om)
    s1 = FactoryBot.create(:relationship_species, parent: FactoryBot.create(:root_taxon_name))
    o1.update!(taxon_name: s1)
    ri1d = ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_object: s1, observation_matrix: om)
    # ri1 and ri1d both refer to r1.
    r1 = om.reload.observation_matrix_rows.first

    ri2 = ObservationMatrixRowItem::Single.create!(observation_object: o2, observation_matrix: om)
    s2 = FactoryBot.create(:relationship_species, name: 'macandcheesei', parent: s1.parent)
    o2.update!(taxon_name: s2)
    ri2d = ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_object: s2, observation_matrix: om)
    # ri2 and ri2d both refer to r2.
    r2 = om.reload.observation_matrix_rows.second

    r = o1.unify(o2, only: [:observation_matrix_rows])
    expect(ObservationMatrixRow.find_by(id: r2.id)).to be_truthy
  end

  specify 'unifies Repositories' do
    a = FactoryBot.create(:valid_repository)
    b = FactoryBot.create(:valid_repository)

    c = FactoryBot.create(:valid_specimen, repository: b, current_repository: b)
    e = FactoryBot.create(:valid_extract, repository: b)

    a.unify(b, target_project_id: project_id)
    expect(b.destroyed?).to be_truthy
    expect(c.reload.current_repository).to eq(a)
    expect(c.reload.repository).to eq(a)
  end

  specify 'community relations are picked up via #unify_relations' do
    a = FactoryBot.create(:valid_serial)
    expect(a.merge_relations.map(&:name)).to include(:sources)
  end

  specify '#relation_targets_community?' do
    a = FactoryBot.create(:valid_serial)

    r = ApplicationEnumeration.klass_reflections(Serial, :belongs_to).select{|a| a.name == :translated_from_serial}.first
    expect(ApplicationEnumeration.relation_targets_community?(r)).to be_truthy
  end

  specify 'unifies Serials with Sources' do
    a = FactoryBot.create(:valid_serial)
    b = FactoryBot.create(:valid_serial)

    c = FactoryBot.create(:valid_source_bibtex, serial: b)

    e = a.unify(b, target_project_id: project_id)

    expect(b.destroyed?).to be_truthy
    expect(a.sources.reload.size).to eq(1)
  end

  specify 'unifies Serials without Sources' do
    a = FactoryBot.create(:valid_serial)
    b = FactoryBot.create(:valid_serial)

    a.unify(b, target_project_id: project_id)
    expect(b.destroyed?).to be_truthy
  end

  specify 'deduplicates Depictions referencing the same image' do
    i = FactoryBot.create(:valid_image)

    a = FactoryBot.create(:valid_depiction, depiction_object: o1, image: i)
    b = FactoryBot.create(:valid_depiction, depiction_object: o2, image: i)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.depictions.size).to eq(1)
  end

  specify 'deduplicates double non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o1, value: 123)
    c = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o2, value: 123, import_predicate:  a.import_predicate)

    b = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o1, value: 456)
    d = FactoryBot.create(:valid_data_attribute_import_attribute, attribute_subject: o2, value: 456, import_predicate: b.import_predicate)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
  end

  specify 'deduplicates double non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123)
    b = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: a.predicate)

    c = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123)
    d = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: c.predicate)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
  end

  specify 'moves Confidences' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c = FactoryBot.create(
      :valid_confidence, confidence_object: b
    )

    a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(a.confidences.size).to eq(1)
  end

  specify 'returns failure when too many relations' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c = FactoryBot.create(
      :valid_confidence, confidence_object: b
    )
    d = FactoryBot.create(
      :valid_confidence, confidence_object: b
    )

    r = a.unify(b, cutoff: 1)
    expect(r[:result][:unified]).to be_falsey
    expect(r[:result][:message]).to include('cutoff')
  end

  specify 'handles BiocurationClassifications when identical' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c = FactoryBot.create(
      :valid_biocuration_classification, biocuration_classification_object: a
    )

    d = FactoryBot.create(
      :valid_biocuration_classification,
      biocuration_classification_object: b,
      biocuration_class: c.biocuration_class)

    e =  a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(BiocurationClassification.all.reload.size).to eq(1)
  end

  specify 'sums BiocurationClassifications when classes differ' do
    a = FactoryBot.create(:valid_specimen)
    b = FactoryBot.create(:valid_specimen)

    c1 = FactoryBot.create(
      :valid_biocuration_classification, biocuration_classification_object: a
    )

    c2 = FactoryBot.create(
      :valid_biocuration_classification, biocuration_classification_object: b
    )

    a.unify(b)

    expect(b.destroyed?).to be_truthy

    a_classifications = a.biocuration_classifications.reload
    expect(a_classifications.pluck(:biocuration_class_id)).to contain_exactly(
      c1.biocuration_class_id, c2.biocuration_class_id
    )
  end

  specify 'if only used then use as "move" not unify' do
    c1 = Citation.create(citation_object: o1, source:, pages: 123)
    c2 = Citation.create(citation_object: o1, source:, pages: 456)

    o1.unify(o2, only: [:citations])

    expect(o2.reload.destroyed?).to be_falsey
    expect(o1.citations.reload.count).to eq(2)
    expect(o1.citations.pluck(:pages)).to contain_exactly('123', '456')
  end

  specify 'merges non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute, attribute_subject: o1, value: 123)
    b = FactoryBot.create(:valid_data_attribute, attribute_subject: o2, value: 456)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
    expect(o1.data_attributes.pluck(:value)).to contain_exactly('123', '456')
  end

  specify 'deduplicates DataAttributes' do
    predicate = FactoryBot.create(:valid_predicate)
    a = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123, predicate: )
    b = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: )

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(1)
    expect(o1.data_attributes.last.value).to eq('123')
  end

  specify 'persists citations on deduplicate DataAttributes' do
    predicate = FactoryBot.create(:valid_predicate)
    a = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o1, value: 123, predicate: )
    b = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: o2, value: 123, predicate: )

    FactoryBot.create(:valid_citation, citation_object: b)

    o1.unify(o2)
    expect(o1.data_attributes.first.citations.size).to eq(1)
  end

  # Only makes sense when observations need to be moved
  specify 'unifies TypeMaterial' do
    a = FactoryBot.create(:valid_type_material)
    b = FactoryBot.create(:valid_type_material)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Only makes sense when observations need to be moved
  specify 'unifies TaxonDetermination' do
    a = FactoryBot.create(:valid_taxon_name)
    b = FactoryBot.create(:valid_taxon_name)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Only makes sense when observations need to be moved
  specify 'unifies TaxonDetermination' do
    a = FactoryBot.create(:valid_taxon_determination)
    b = FactoryBot.create(:valid_taxon_determination)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Source with target_project_id (when Source is "naked")' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    a.unify(b, target_project_id: o1.project_id)
    expect(b.destroyed?).to be_truthy
  end

  specify 'does not unify Source without target_project_id' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    a.unify(b)
    expect(b.destroyed?).to be_falsey
  end

  specify 'does not unify Source when cross-project use present' do
    project = FactoryBot.create(:valid_project)
    o3 = FactoryBot.create(:valid_otu, project:)

    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    c = FactoryBot.create(:valid_citation, project:, source: b, citation_object: o3)

    a.unify(b)
    expect(b.destroyed?).to be_falsey
  end

  specify 'does unify Source if specific to project' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    c = FactoryBot.create(:valid_citation, source: a, citation_object: o1)
    d = FactoryBot.create(:valid_citation, source: b, citation_object: o2)

    a.unify(b, target_project_id: project_id )

    expect(b.destroyed?).to be_truthy
    expect(d.reload.source).to eq(a)
  end

  # !! Requires more thorough testing with items etc.
  specify 'unifies ObservationMatrix' do
    a = FactoryBot.create(:valid_observation_matrix)
    b = FactoryBot.create(:valid_observation_matrix)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Only useful to annotations from one to another
  specify 'unifies Observation' do
    a = FactoryBot.create(:valid_observation)
    b = FactoryBot.create(:valid_observation)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Loan' do
    a = FactoryBot.create(:valid_loan)
    b = FactoryBot.create(:valid_loan)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Useful in replacing versions of self if necessary,
  # but image de-duplication already happens
  specify 'unifies Image' do
    a = FactoryBot.create(:valid_image)

    b = Image.create!(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'foo.png',
      ), 'image/png'),
    )

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Image — reroutes Depictions to the surviving image' do
    a = FactoryBot.create(:valid_image)
    b = Image.create!(
      image_file: Rack::Test::UploadedFile.new(Spec::Support::Utilities::Files.generate_tiny_random_sized_png(
        file_name: 'foo.png',
      ), 'image/png'),
    )
    depiction = FactoryBot.create(:valid_depiction, image: b, depiction_object: o1)

    a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(depiction.reload.image).to eq(a)
  end

  specify 'unifies Document' do
    a = FactoryBot.create(:valid_document)
    b = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        Spec::Support::Utilities::Files.generate_pdf(file_name: 'doc_b.pdf', pages: 2),
        'application/pdf'
      )
    )

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Document — reroutes Documentation to the surviving document' do
    a = FactoryBot.create(:valid_document)
    b = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        Spec::Support::Utilities::Files.generate_pdf(file_name: 'doc_b.pdf', pages: 2),
        'application/pdf'
      )
    )
    documentation = Documentation.create!(document: b, documentation_object: o1)

    a.unify(b)

    expect(b.destroyed?).to be_truthy
    expect(documentation.reload.document).to eq(a)
  end

  specify 'unifies Georeference' do
    a = FactoryBot.create(:valid_georeference)
    b = FactoryBot.create(:valid_georeference)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # Tries to move the required TD, which isn't allowed
  #  - perhaps dup and not add error then destroy @ end?
  specify 'unifies FieldOccurrence' do
    a = FactoryBot.create(:valid_field_occurrence)
    b = FactoryBot.create(:valid_field_occurrence)

    r = a.unify(b)
    expect(b.destroyed?).to be_truthy
    expect(a.taxon_determinations.reload.size).to eq(2)
  end

  # Tries to move the required TD, which isn't allowed
  #  - perhaps dup and not add error then destroy @ end?
  specify 'unifies FieldOccurrence with CEs linked to COs' do
    a = FactoryBot.create(:valid_field_occurrence)
    ce = a.collecting_event
    b = FactoryBot.create(:valid_field_occurrence, collecting_event: ce)

    s = FactoryBot.create(:valid_specimen, collecting_event: ce)

    r = a.unify(b)
    expect(b.destroyed?).to be_truthy
    expect(a.taxon_determinations.reload.size).to eq(2)
  end



  specify 'unifies Extract' do
    a = FactoryBot.create(:valid_extract)
    b = FactoryBot.create(:valid_extract)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifying Descriptors moves observation_matrix_column_items to the surviving descriptor' do
    om = FactoryBot.create(:valid_observation_matrix)
    d1 = FactoryBot.create(:valid_descriptor)
    d2 = FactoryBot.create(:valid_descriptor)
    col_item = ObservationMatrixColumnItem::Single::Descriptor.create!(observation_matrix: om, descriptor: d2)

    d1.unify(d2)

    expect(d2.destroyed?).to be_truthy
    expect(ObservationMatrixColumnItem.where(id: col_item.id).exists?).to be(true)
    expect(col_item.reload.descriptor_id).to eq(d1.id)
  end

  specify 'unifying Keywords moves observation_matrix_column_items to the surviving keyword' do
    om = FactoryBot.create(:valid_observation_matrix)
    k1 = FactoryBot.create(:valid_keyword)
    k2 = FactoryBot.create(:valid_keyword)
    col_item = ObservationMatrixColumnItem::Dynamic::Tag.create!(observation_matrix: om, controlled_vocabulary_term: k2)

    k1.unify(k2)

    expect(k2.destroyed?).to be_truthy
    expect(ObservationMatrixColumnItem.where(id: col_item.id).exists?).to be(true)
    expect(col_item.reload.controlled_vocabulary_term_id).to eq(k1.id)
  end

  specify 'unifying Keywords moves observation_matrix_row_items to the surviving keyword' do
    om = FactoryBot.create(:valid_observation_matrix)
    k1 = FactoryBot.create(:valid_keyword)
    k2 = FactoryBot.create(:valid_keyword)
    row_item = ObservationMatrixRowItem::Dynamic::Tag.create!(observation_matrix: om, observation_object: k2)

    k1.unify(k2)

    expect(k2.destroyed?).to be_truthy
    expect(ObservationMatrixRowItem.where(id: row_item.id).exists?).to be(true)
    expect(row_item.reload.observation_object_id).to eq(k1.id)
  end

  # !! Can unify *across* Descriptors as well
  specify 'unifies CharacterState' do
    a = FactoryBot.create(:valid_character_state)
    b = FactoryBot.create(:valid_character_state)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Descriptor' do
    a = FactoryBot.create(:valid_descriptor)
    b = FactoryBot.create(:valid_descriptor)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'does not unify different kinds of ControlledVocabularyTerm' do
    a = FactoryBot.create(:valid_predicate)
    b = FactoryBot.create(:valid_keyword)

    a.unify(b)
    expect(b.destroyed?).to be_falsey
  end

  specify 'unifies ControlledVocabularyTerms' do
    a = FactoryBot.create(:valid_keyword)
    b = FactoryBot.create(:valid_keyword)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  # No point in unify here, is there?
  xspecify 'unifies Depiction' do
  end

  # Not exposed in UI
  # !? What does this mean, merge text?
  xspecify 'unifies Content' do
    a = FactoryBot.create(:valid_content)
    b = FactoryBot.create(:valid_content)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies Container' do
    a = FactoryBot.create(:valid_container)
    b = FactoryBot.create(:valid_container)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies CollectionObject' do
    a = FactoryBot.create(:valid_collection_object)
    b = FactoryBot.create(:valid_collection_object)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
  end

  specify 'unifies CollectingEvent' do
    ce1 = FactoryBot.create(:valid_collecting_event)
    ce2 = FactoryBot.create(:valid_collecting_event)

    ce1.unify(ce2)
    expect(ce2.destroyed?).to be_truthy
  end

  specify 'unifies BiologicalAssociationsGraph' do
    bag1 = FactoryBot.create(:valid_biological_associations_graph)
    bag2 = FactoryBot.create(:valid_biological_associations_graph)

    bag1.unify(bag2)
    expect(bag2.destroyed?).to be_truthy
  end

  specify 'unifies BiologicalAssocations' do
    o3 = FactoryBot.create(:valid_otu)

    ba0 = FactoryBot.create(:valid_biological_association, biological_association_subject: o1, biological_association_object: o3)
    ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: o3)

    b = ba0.unify(ba1)

    expect(ba1.destroyed?).to be_truthy
    expect(BiologicalAssociation.all.reload.count).to eq(1)
  end

  specify 'unify preserves once-removed citations differing only by page / AssertedDstribution test ' do
    # Create a GA and a non-target record
    ad0 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source:)
    ad1 = AssertedDistribution.create!(
      asserted_distribution_object: o2,
      source:,
      asserted_distribution_shape: ad0.asserted_distribution_shape
    )

    ad0.origin_citation.update!(pages: 123)
    ad1.origin_citation.update!(pages: 456)

    b = ad0.unify(ad1)

    expect(ad1.destroyed?).to be_truthy

    expect(ad0.citations.reload.size).to eq(2)
    expect(ad0.citations.pluck(:pages)).to contain_exactly('123', '456')
  end

  specify 'unify preserves citations differing by pages' do
    c1 = Citation.create(citation_object: o1, source:, pages: 123)
    c2 = Citation.create(citation_object: o1, source:, pages: 456)

    o1.unify(o2)

    expect(o1.citations.reload.count).to eq(2)
    expect(o1.citations.pluck(:pages)).to contain_exactly('123', '456')
  end

  specify '#unify' do
    expect(o1.unify(o2)).to be_truthy
  end

  specify 'unify destroys by default' do
    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
  end

  specify 'unify does not destroy with preview' do
    o1.unify(o2, preview: true)
    expect(o2.destroyed?).to be_falsey
  end

  specify 'unify moves annotations' do
    n = FactoryBot.create(:valid_note, note_object: o2)

    o1.unify(o2)
    expect(o1.notes.reload.count).to eq(1)
  end

  specify 'unify moves has_many' do
    s = FactoryBot.create(:valid_specimen)
    n = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, otu: o2)

    o1.unify(o2)
    expect(o1.taxon_determinations.reload.count).to eq(1)
  end

  specify 'unify handles duplicate tags when both objects share the same keyword' do
    k = FactoryBot.create(:valid_keyword)
    Tag.create!(tag_object: o1, keyword: k)
    Tag.create!(tag_object: o2, keyword: k)

    result = o1.unify(o2)

    expect(result[:result][:unified]).to be_truthy
    expect(o2.destroyed?).to be_truthy
    expect(o1.tags.reload.count).to eq(1)
    expect(o1.tags.first.keyword).to eq(k)
  end

  specify '#identical' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape)

    ad2.asserted_distribution_object = o1

    expect(ad2.identical.first).to eq(ad1)
  end

  #
  # Model/Context specific handling
  #

  specify 'unify handles Auto UUIDs' do
    o1.unify(o2)

    expect(o1.identifiers.reload.size).to eq(2)
  end

  # See also TNR
  #  When we loop through as has_many
  #     and we are updating a record A
  #      and it fails with an error * on the class being unified *
  #         then we find the identical duplicate record B
  #             and we unify A -> B
  #               and we delete A
  #
  specify 'unify one degree of seperation' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2)

    expect(AssertedDistribution.find_by(id: ad2.id)).to eq(nil)
    expect(n.reload.note_object).to eq(ad1)
    expect(o2.destroyed?).to be_truthy
  end

  specify 'unify one degree of seperation - records deduplication result in preview' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2, preview: true)

    expect( b[:details]['Asserted distributions'].dig(:deduplicated)).to eq(1)
  end

  specify 'unify one degree of seperation - records deduplication result' do
    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2)

    expect( b[:details]['Asserted distributions'].dig(:deduplicated)).to eq(1)
  end

  context 'when the nested unify inside deduplicate_update_target fails' do
    let(:om) { ObservationMatrix.create!(name: 'BugTest') }
    let!(:row1) { FactoryBot.create(:valid_observation_matrix_row, observation_object: o1, observation_matrix: om) }
    let!(:row2) { FactoryBot.create(:valid_observation_matrix_row, observation_object: o2, observation_matrix: om) }

    before do
      # At time of writing there are no second-level model associations that
      # could return {unified: false} from the secondary unify call, but there's
      # no reason that might not happen in the future.
      allow_any_instance_of(ObservationMatrixRow).to receive(:unify)
        .and_return({result: {unified: false, message: 'nested failure'}, details: {}})
    end

    specify 'unify returns unified: false' do
      result = o1.unify(o2)
      expect(result[:result][:unified]).to be(false)
    end

    specify 'o2 is not destroyed' do
      o1.unify(o2)
      expect(Otu.where(id: o2.id).exists?).to be(true)
    end

    specify 'details report unmerged count of 1 (not deduplicated)' do
      result = o1.unify(o2)
      expect(result[:details]['Observation matrix rows'][:unmerged]).to eq(1)
    end
  end

  # Generalize to all annotations.
  #
  # If unify would create two identical citations anywhere
  # during the process, then destroy one of them.
  #
  #   then destroy one of them
  #
  #
  #
  specify 'would-be duplicate citations do not halt unify' do
    s = FactoryBot.create(:valid_source)

    ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2, asserted_distribution_shape: ad1.asserted_distribution_shape, source: s)

    expect(Citation.all.size).to eq(2)

    b = o1.unify(o2)

    expect(o2.destroyed?).to be_truthy
    expect(Citation.all.size).to eq(1)
  end

  specify 'unifies TaxonNames when both have the same OriginalCombination relationship type' do
    genus = FactoryBot.create(:relationship_genus)
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)

    r_keep = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: keep)
    r_destroy = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: destroy)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(TaxonNameRelationship.find_by(id: r_destroy.id)).to be_nil
    expect(TaxonNameRelationship.find_by(id: r_keep.id)).not_to be_nil
  end

  specify 'unifies TaxonNames with duplicate OriginalCombination - counts as deduplicated in result' do
    genus = FactoryBot.create(:relationship_genus)
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)

    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: keep)
    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      subject_taxon_name: genus, object_taxon_name: destroy)

    result = keep.unify(destroy)

    expect(result[:details]['Related taxon name relationships'][:deduplicated]).to eq(1)
  end

  specify 'unifies TaxonNames when both are subjects of the same TNR to the same object' do
    keep = FactoryBot.create(:relationship_species)
    destroy = FactoryBot.create(:relationship_species)
    valid_name = FactoryBot.create(:relationship_species)

    r_keep = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: keep, object_taxon_name: valid_name)
    r_destroy = FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: destroy, object_taxon_name: valid_name)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(TaxonNameRelationship.find_by(id: r_destroy.id)).to be_nil
    expect(TaxonNameRelationship.find_by(id: r_keep.id)).not_to be_nil
  end

  # Aus bus (destroy) and Cus dus (keep) both exist, and some other name is
  # a Synonym *of* Aus bus (i.e. Aus bus is the *object* of that TNR, and
  # Aus bus's id is cached on the synonym's cached_valid_taxon_name_id).
  # keep.unify(destroy) moves destroy's taxon_name_relationships (including
  # the synonym TNR) over to keep, then destroys Aus bus. The synonym's
  # cached_valid_taxon_name_id, however, still points at the now-destroyed
  # Aus bus, so anything that resolves #valid_taxon_name off the synonym
  # blows up trying to load a name that no longer exists.
  specify 'unifies TaxonNames - synonym cached_valid_taxon_name_id follows the object of a Synonym relationship' do
    keep = FactoryBot.create(:relationship_species)    # Cus dus
    destroy = FactoryBot.create(:relationship_species) # Aus bus
    synonym = FactoryBot.create(:relationship_species)  # something else, synonym of Aus bus

    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: synonym, object_taxon_name: destroy)

    expect(synonym.reload.cached_valid_taxon_name_id).to eq(destroy.id)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(synonym.reload.cached_valid_taxon_name_id).to eq(keep.id)
    expect(synonym.valid_taxon_name).to eq(keep)
  end

  # Same shape, opposite side of the TNR: here Aus bus (destroy) is itself the
  # *subject* (a Synonym) of a relationship pointing to some unrelated valid
  # name, rather than being the object another name is a synonym of.
  # keep.unify(destroy) moves that relationship's subject_taxon_name over to
  # Cus dus (keep), which should itself pick up destroy's cached_valid_taxon_name_id.
  specify 'unifies TaxonNames - keep picks up cached_valid_taxon_name_id when it becomes the subject of a Synonym relationship' do
    keep = FactoryBot.create(:relationship_species)       # Cus dus
    destroy = FactoryBot.create(:relationship_species)    # Aus bus, a synonym
    valid_name = FactoryBot.create(:relationship_species) # the name Aus bus is a synonym of

    FactoryBot.create(:taxon_name_relationship,
      type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
      subject_taxon_name: destroy, object_taxon_name: valid_name)

    expect(destroy.reload.cached_valid_taxon_name_id).to eq(valid_name.id)
    expect(keep.reload.cached_valid_taxon_name_id).to eq(keep.id)

    keep.unify(destroy)

    expect(destroy.destroyed?).to be_truthy
    expect(keep.reload.cached_valid_taxon_name_id).to eq(valid_name.id)
    expect(keep.valid_taxon_name).to eq(valid_name)
  end

  specify 'InvalidForeignKey error' do
    keep = FactoryBot.create(:valid_topic)
    remove = FactoryBot.create(:valid_topic)

    # Simulate a DB-level FK violation on destroy of the "remove" record.
    allow(remove).to receive(:destroy!).and_raise(
      ActiveRecord::InvalidForeignKey.new('PG::ForeignKeyViolation: update or delete on table ...')
    )

    result = keep.unify(remove)

    expect(result[:result][:unified]).to be(false)

    error = result[:details][:Object][:errors].first
    expect(error[:id]).to eq(remove.id)
    expect(error[:exception]).to eq('ActiveRecord::InvalidForeignKey')
    expect(error[:message]).to match(/ForeignKey|foreign key|PG::/i)
  end

  specify 'unifying TaxonNames moves observation_matrix_row_items to the surviving taxon name' do
    om = FactoryBot.create(:valid_observation_matrix)
    t1 = FactoryBot.create(:valid_taxon_name)
    t2 = FactoryBot.create(:valid_taxon_name)
    row_item = ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_matrix: om, observation_object: t2)
    t1.unify(t2)
    expect(t2.destroyed?).to be_truthy
    expect(ObservationMatrixRowItem.where(id: row_item.id).exists?).to be(true)
    expect(row_item.reload.observation_object_id).to eq(t1.id)
  end

  context 'acts_as_list positions' do
    let(:ns) { FactoryBot.create(:valid_namespace) }
    let(:ce1) { FactoryBot.create(:valid_collecting_event) }
    let(:ce2) { FactoryBot.create(:valid_collecting_event) }

    context 'when only the removed CE has identifiers' do
      let!(:id_ce2_secondary) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-B') }
      let!(:id_ce2_preferred) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-A') }

      specify 'ce2 preferred becomes ce1 preferred' do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).first.id).to eq(id_ce2_preferred.id)
      end

      specify 'ce2 secondary is last' do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).last.id).to eq(id_ce2_secondary.id)
      end
    end

    context 'when both CEs have an identifier' do
      let!(:id_ce1) { Identifier::Local::Event.create!(identifier_object: ce1, namespace: ns, identifier: 'CE1-A') }
      before {
        Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-A')
      }

      specify "ce1's original identifier remains preferred after unify" do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).first.id).to eq(id_ce1.id)
      end
    end

    context 'when both CEs have multiple identifiers' do
      # ce1: create B first (pos 2), then A (pos 1) — A is preferred
      let!(:id_ce1_secondary) { Identifier::Local::Event.create!(identifier_object: ce1, namespace: ns, identifier: 'CE1-B') }
      let!(:id_ce1_preferred) { Identifier::Local::Event.create!(identifier_object: ce1, namespace: ns, identifier: 'CE1-A') }
      # ce2: create D first (pos 2), then C (pos 1) — C is preferred
      let!(:id_ce2_secondary) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-D') }
      let!(:id_ce2_preferred) { Identifier::Local::Event.create!(identifier_object: ce2, namespace: ns, identifier: 'CE2-C') }

      specify 'ce1 identifiers retain their order, followed by ce2 identifiers in their original order' do
        ce1.unify(ce2)
        expect(ce1.reload.identifiers.order(:position).pluck(:id)).to eq(
          [id_ce1_preferred.id, id_ce1_secondary.id, id_ce2_preferred.id, id_ce2_secondary.id]
        )
      end
    end

    context 'collector role order during unify' do
      let(:ce1) { FactoryBot.create(:valid_collecting_event) }
      let(:ce2) { FactoryBot.create(:valid_collecting_event) }
      let(:person1) { FactoryBot.create(:valid_person) }
      let(:person2) { FactoryBot.create(:valid_person) }
      let(:person3) { FactoryBot.create(:valid_person) }
      let(:person4) { FactoryBot.create(:valid_person) }

      # Bottom-insertion: each new role appends to the end, so creation order = position order.
      let!(:role_ce1_a) { Collector.create!(person: person1, role_object: ce1) }
      let!(:role_ce1_b) { Collector.create!(person: person2, role_object: ce1) }
      let!(:role_ce2_a) { Collector.create!(person: person3, role_object: ce2) }
      let!(:role_ce2_b) { Collector.create!(person: person4, role_object: ce2) }

      before { ce1.unify(ce2) }

      specify 'ce2 is destroyed' do
        expect(ce2.destroyed?).to be_truthy
      end

      specify 'all four collector roles are on ce1' do
        expect(ce1.collector_roles.reload.count).to eq(4)
      end

      specify 'ce1 original collectors retain their relative order, followed by ce2 collectors in their original order' do
        ordered_ids = ce1.collector_roles.reload.order(:position).pluck(:id)
        expect(ordered_ids).to eq([role_ce1_a.id, role_ce1_b.id, role_ce2_a.id, role_ce2_b.id])
      end
    end
  end

  context 'Georeferences on Collecting Events' do
    let(:ce1) { FactoryBot.create(:valid_collecting_event) }
    let(:ce2) { FactoryBot.create(:valid_collecting_event) }

    context 'when the removed CE has a georeference' do
      before { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce2) }

      specify 'the removed CE is destroyed' do
        ce1.unify(ce2)
        expect(ce2.destroyed?).to be_truthy
      end
    end

    context 'when the target CE also has a georeference' do
      let!(:georef1) { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce1) }

      before { Georeference::Wkt.create!(wkt: 'POINT (20 20)', collecting_event: ce2) }

      specify 'the target CE retains its original georeference as preferred' do
        ce1.unify(ce2)
        expect(ce1.reload.preferred_georeference.id).to eq(georef1.id)
      end

      specify 'the moved georeference is positioned after the existing one' do
        ce1.unify(ce2)
        expect(ce1.reload.georeferences.order(:position).last.geographic_item.geo_object.to_s).to include('20.0 20.0')
      end

      specify 'geographic_name_classification_method is :preferred_georeference' do
        ce1.unify(ce2)
        expect(ce1.reload.send(:geographic_name_classification_method)).to eq(:preferred_georeference)
      end
    end

    context 'when the target CE has no georeference and the removed CE has two' do
      let!(:georef_secondary) { Georeference::Wkt.create!(wkt: 'POINT (20 20)', collecting_event: ce2) }
      let!(:georef_preferred) { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce2) }

      specify 'the target CE gains two georeferences' do
        ce1.unify(ce2)
        expect(ce1.reload.georeferences.count).to eq(2)
      end

      specify "ce2's preferred georeference becomes ce1's preferred georeference" do
        ce1.unify(ce2)
        expect(ce1.reload.preferred_georeference.id).to eq(georef_preferred.id)
      end

      specify 'geographic_name_classification_method is :preferred_georeference' do
        ce1.unify(ce2)
        expect(ce1.reload.send(:geographic_name_classification_method)).to eq(:preferred_georeference)
      end
    end

    context 'when both CEs have georeferences' do
      let!(:georef_ce1) { Georeference::Wkt.create!(wkt: 'POINT (1 1)', collecting_event: ce1) }
      # ce2: create secondary first (pos 2), then preferred (pos 1)
      let!(:georef_ce2_secondary) { Georeference::Wkt.create!(wkt: 'POINT (30 30)', collecting_event: ce2) }
      let!(:georef_ce2_preferred) { Georeference::Wkt.create!(wkt: 'POINT (20 20)', collecting_event: ce2) }

      specify 'the target CE has all three georeferences' do
        ce1.unify(ce2)
        expect(ce1.reload.georeferences.count).to eq(3)
      end

      specify "ce1's georeferences retain their order, followed by ce2's in their original order, with ce1's first remaining preferred" do
        ce1.unify(ce2)
        ordered = ce1.reload.georeferences.order(:position)
        expect(ordered.pluck(:id)).to eq([georef_ce1.id, georef_ce2_preferred.id, georef_ce2_secondary.id])
        expect(ce1.preferred_georeference.id).to eq(georef_ce1.id)
      end
    end

    context 'georeference subtype associations excluded from merge_relations' do
      # verbatim_data_georeference (has_one) and geo_locate_georeferences
      # (has_many, dependent: :destroy) are excluded from merge_relations by the
      # class_name: rule.
      # They are moved as part of the base :georeferences association instead.
      # If the move didn't happen, ce2's destruction would cascade-delete these
      # records via their own dependent: :destroy. The specs below fail under
      # that regression.

      specify 'VerbatimData georeference is moved to the target CE and accessible via has_one' do
        ce2_with_coords = FactoryBot.create(:valid_collecting_event,
          verbatim_latitude: '40.0',
          verbatim_longitude: '-88.0')
        vd = Georeference::VerbatimData.create!(collecting_event: ce2_with_coords)
        ce1.unify(ce2_with_coords)
        expect(ce1.reload.verbatim_data_georeference.id).to eq(vd.id)
      end

      specify 'GeoLocate georeference survives ce2 destruction and is accessible on ce1' do
        geo_locate = FactoryBot.create(:valid_georeference_geo_locate, collecting_event: ce2)
        ce1.unify(ce2)
        expect(ce1.reload.geo_locate_georeferences.map(&:id)).to include(geo_locate.id)
      end
    end

    context 'when ce1 has a geographic_area that does not contain ce2s georeference' do
      # ce1's geographic area is a small box from (0,0) to (5,5).
      # ce2's georeference is at POINT(10 10), outside that box.
      # The unify should fail entirely: unified=false, ce2 and its georef survive.
      let(:earth) { FactoryBot.create(:earth_geographic_area) }
      let(:ga_shape) {
        GeographicItem.create!(geography: 'POLYGON((0 0 0, 0 5 0, 5 5 0, 5 0 0, 0 0 0))')
      }
      let!(:ga) {
        gat = GeographicAreaType.find_or_create_by!(name: 'Test')
        a = GeographicArea.create!(
          name: 'Small area',
          data_origin: 'Test Data',
          geographic_area_type: gat,
          parent: earth)
        GeographicAreasGeographicItem.create!(geographic_item: ga_shape, geographic_area: a)
        a
      }
      let(:ce1_with_ga) { FactoryBot.create(:valid_collecting_event, geographic_area: ga) }
      let!(:georef_outside) { Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: ce2) }

      specify 'unify returns unified: false' do
        result = ce1_with_ga.unify(ce2)
        expect(result[:result][:unified]).to be(false)
      end

      specify 'ce2 is not destroyed' do
        ce1_with_ga.unify(ce2)
        expect(CollectingEvent.where(id: ce2.id).exists?).to be(true)
      end

      specify 'ce2s georeference is not destroyed' do
        ce1_with_ga.unify(ce2)
        expect(Georeference.where(id: georef_outside.id).exists?).to be(true)
      end
    end
  end

  # Linting spec — catches the class_name: exclusion bug before it ships.
  #
  # inferred_relations drops any has_many/has_one that carries class_name:
  # (the rule exists to skip convenience subtype aliases and through relations).
  # When a *canonical* relation uses class_name: (e.g. because the target is a
  # namespaced class), it is silently excluded from merge_relations, so records
  # become untethered or are destroyed rather than being moved to the survivor.
  #
  # Legitimately excluded:
  #   - dependent: :restrict_with_error — destroy fails gracefully
  #   - through: relations — handled via their base relation
  #   - cache FK relations — recalculated automatically, not manually reassigned
  #   - closure_tree relations (:children, :ancestor_hierarchies, etc.) — gem-managed
  #   - Role subtypes — covered by FK-match to the base :roles relation (HasRoles)
  #   - ActiveStorage attachments — managed by Rails internals
  #   - Relations already in used_inferred_relations or covered by FK match
  #
  specify 'no has_many/has_one with class_name: goes unhandled during unify' do
    uncovered = []

    UNIFIABLE_MODELS.each do |name|
      klass = name.safe_constantize
      expect(klass).not_to be_nil, "UNIFIABLE_MODELS contains '#{name}' but it cannot be constantized"

      instance = klass.new
      expect(instance).to be_a(ApplicationRecord), "UNIFIABLE_MODELS contains '#{name}' but instantiation failed"

      used_names = instance.used_inferred_relations.map(&:name).to_set
      used_by_fk = instance.used_inferred_relations
        .group_by { |r| [r.foreign_key.to_s, r.options[:as]] }

      [:has_many, :has_one].each do |rel_type|
        ApplicationEnumeration.klass_reflections(klass, rel_type).each do |r|
          next unless r.options[:class_name].present?
          next if r.options[:dependent] == :restrict_with_error
          next if r.options[:through].present?
          next if r.foreign_key.to_s =~ /cache/
          next if r.name.to_s.match(/related/) # unify handles these in this case
          next if used_names.include?(r.name)
          next if Shared::Unify::EXCLUDE_RELATIONS.include?(r.name.to_sym)

          # closure_tree injects :children, :ancestor_hierarchies, and
          # :descendant_hierarchies. These are gem-managed and auto-maintained;
          # unify should not touch them.
          next if klass.ancestors.include?(ClosureTree::Model) &&
            %i[children ancestor_hierarchies descendant_hierarchies].include?(r.name)

          # ActiveStorage attachments are managed by Rails internals / custom
          # after_destroy hooks, not by the unify merge loop.
          next if r.options[:class_name].to_s.include?('ActiveStorage')

          # A base relation in used_inferred_relations with the same FK covers
          # these records (e.g. :roles covers :collector_roles).
          covered = used_by_fk[[r.foreign_key.to_s, r.options[:as]]].present?
          next if covered

          uncovered << "#{klass}##{r.name} " \
                       "(class_name: #{r.options[:class_name]}, " \
                       "dependent: #{r.options[:dependent].inspect})"
        end
      end
    end

    expect(uncovered).to be_empty,
      "has_many/has_one with class_name: excluded from unify merge_relations with no covering base relation.\n" \
      "Records in these relations will be untethered or destroyed rather than moved to the survivor.\n" \
      "Add the relation to unify_relations or ensure a covering base relation exists:\n" \
      "  #{uncovered.join("\n  ")}"
  end

  # Linting spec — catches missing inverse_of: on relations for models that
  # are actually exposed for unification (UNIFIABLE_MODELS).
  #
  # used_inferred_relations requires inverse_of: to be present so it can
  # reassign the FK during the merge loop. A relation that passes
  # inferred_relations but lacks inverse_of: is silently dropped from
  # merge_relations. Even if the relation is not dependent: :destroy, the
  # records become untethered — pointing at the destroyed object or nullified —
  # which is also data loss from the unify perspective.
  # Only dependent: :restrict_with_error is safe to skip, as it causes the
  # destroy to fail gracefully rather than silently losing data.
  specify 'no relation in inferred_relations is missing inverse_of: on unifiable models' do
    uncovered = []

    UNIFIABLE_MODELS.each do |name|
      klass = name.safe_constantize
      expect(klass).not_to be_nil, "UNIFIABLE_MODELS contains '#{name}' but it cannot be constantized"

      instance = klass.new
      expect(instance).to be_a(ApplicationRecord), "UNIFIABLE_MODELS contains '#{name}' but instantiation failed"

      instance.inferred_relations.each do |r|
        next if r.options[:dependent] == :restrict_with_error
        next if r.options[:inverse_of].present?

        uncovered << "#{name}##{r.name} (dependent: #{r.options[:dependent].inspect})"
      end
    end

    expect(uncovered).to be_empty,
      "Relations in inferred_relations missing inverse_of: on unifiable models.\n" \
      "Records in these relations will be untethered or destroyed rather than moved to the survivor.\n" \
      "Add inverse_of: to the relation so unify can move records to the survivor:\n" \
      "  #{uncovered.join("\n  ")}"
  end

end

class TestUnify < ApplicationRecord
  include FakeTable
  include Shared::Unify
end
