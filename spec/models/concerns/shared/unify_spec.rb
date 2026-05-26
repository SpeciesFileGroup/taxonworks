require 'rails_helper'

describe 'Shared::Unify', type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }


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

  #
  # acts_as_list position ordering — general fix in Shared::Unify
  #
  # These specs cover the generic re-sort added to Shared::Unify for has_many
  # associations on acts_as_list models.  After a unify, the surviving object's
  # existing records should keep their original relative order, immediately followed
  # by the removed object's records in their original order.
  #

  context 'collector role order during unify' do
    # Use CollectingEvent + Collector so that roles carry a project_id and are
    # moved by the unify merge loop (SourceAuthor roles on the community Source
    # model have nil project_id and are filtered out by the project-scope guard).
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

  context 'depiction order during unify' do
    # Reuses o1 and o2 from the top-level lets.
    # Bottom-insertion: each new depiction appends to the end, so creation order = position order.
    let!(:dep_o1_a) { FactoryBot.create(:valid_depiction, depiction_object: o1) }
    let!(:dep_o1_b) { FactoryBot.create(:valid_depiction, depiction_object: o1) }
    let!(:dep_o2_a) { FactoryBot.create(:valid_depiction, depiction_object: o2) }
    let!(:dep_o2_b) { FactoryBot.create(:valid_depiction, depiction_object: o2) }

    before { o1.unify(o2) }

    specify 'o2 is destroyed' do
      expect(o2.destroyed?).to be_truthy
    end

    specify 'all four depictions are on o1' do
      expect(o1.depictions.reload.count).to eq(4)
    end

    specify 'o1 depictions retain their relative order, followed by o2 depictions in their original order' do
      ordered_ids = o1.depictions.reload.order(:position).pluck(:id)
      expect(ordered_ids).to eq([dep_o1_a.id, dep_o1_b.id, dep_o2_a.id, dep_o2_b.id])
    end
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

  # Linting spec — catches the class_name: exclusion bug before it ships.
  #
  # inferred_relations drops any has_many/has_one that carries class_name:
  # (the rule exists to skip convenience subtype aliases and through relations).
  # When a *canonical* relation uses class_name: (e.g. because the target is a
  # namespaced class), it is silently excluded from merge_relations, so records
  # are destroyed with the removed object instead of being moved to the survivor.
  #
  # This spec flags every has_many/has_one that:
  #   1. has class_name: (excluded by inferred_relations)
  #   2. has dependent: :destroy or :delete_all (data loss on destroy)
  #   3. is NOT in used_inferred_relations (not already handled)
  #   4. is NOT covered by a relation that IS in used_inferred_relations and
  #      shares the same foreign key — which would mean a base relation moves
  #      the same records (e.g. :roles covers :collector_roles, :editor_roles, …)
  #
  specify 'no has_many/has_one with class_name: and dependent: destroy goes unhandled during unify' do
    uncovered = []

    ApplicationEnumeration.data_models.each do |klass|
      instance = klass.new rescue next

      used_names  = instance.used_inferred_relations.map(&:name).to_set
      used_by_fk  = instance.used_inferred_relations
                             .group_by { |r| [r.foreign_key.to_s, r.options[:as]] }

      [:has_many, :has_one].each do |rel_type|
        ApplicationEnumeration.klass_reflections(klass, rel_type).each do |r|
          next unless r.options[:class_name].present?
          next unless [:destroy, :delete_all].include?(r.options[:dependent])
          next if r.name.to_s.match(/related/)
          next if used_names.include?(r.name)

          # Role subtypes (Collector, Verifier, …) are covered by the base :roles
          # relation added by HasRoles on models like CollectingEvent.
          # Person is a special case: it uses its own merge_with/hard_merge path
          # rather than Shared::Unify, so its role subtype relations never enter
          # the unify merge loop at all.
          target_klass = r.options[:class_name].sub(/\A::/, '').safe_constantize
          next if target_klass && target_klass.ancestors.include?(Role)

          # ActiveStorage attachments are managed by Rails internals / custom
          # after_destroy hooks, not by the unify merge loop.
          next if r.options[:class_name].to_s.include?('ActiveStorage')

          # A base relation in used_inferred_relations with the same FK covers
          # these records (e.g. :roles covers :collector_roles).
          covered = used_by_fk[[r.foreign_key.to_s, r.options[:as]]].present?

          uncovered << "#{klass}##{r.name} " \
                       "(class_name: #{r.options[:class_name]}, " \
                       "dependent: :#{r.options[:dependent]})" unless covered
        end
      end
    end

    expect(uncovered).to be_empty,
      "has_many/has_one with class_name: and dependent: :destroy excluded from " \
      "unify merge_relations with no covering base relation.\n" \
      "Add the relation to unify_relations or ensure a covering base relation exists:\n" \
      "  #{uncovered.join("\n  ")}"
  end

end

class TestUnify < ApplicationRecord
  include FakeTable
  include Shared::Unify
end
