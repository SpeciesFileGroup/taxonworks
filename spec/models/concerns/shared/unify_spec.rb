require 'rails_helper'

describe 'Shared::Unify', type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }

  specify 'merges non-unique DataAttributes' do
    a = FactoryBot.create(:valid_data_attribute, attribute_subject: o1, value: 123)
    b = FactoryBot.create(:valid_data_attribute, attribute_subject: o2, value: 456)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
    expect(o1.data_attributes.reload.size).to eq(2)
    expect(o1.data_attributes.last.value).to eq('456')
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

  specify 'unifies Source' do
    a = FactoryBot.create(:valid_source)
    b = FactoryBot.create(:valid_source)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
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
        file_name: "foo.png",
      ), 'image/png'),
    )

    a.unify(b)
    expect(b.destroyed?).to be_truthy
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

  specify 'unifies Extract' do
    a = FactoryBot.create(:valid_extract)
    b = FactoryBot.create(:valid_extract)

    a.unify(b)
    expect(b.destroyed?).to be_truthy
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
    ad0 = FactoryBot.create(:valid_asserted_distribution, otu: o1, source:)
    ad1 = AssertedDistribution.create!(
      otu: o2,
      source:,
      geographic_area: ad0.geographic_area
    )

    ad0.origin_citation.update!(pages: 123)
    ad1.origin_citation.update!(pages: 456)

    b = ad0.unify(ad1)

    expect(ad1.destroyed?).to be_truthy

    expect(ad0.citations.reload.size).to eq(2)
    expect(ad0.citations.last.pages).to eq('456')
  end

  specify 'unify preserves citations differing by pages' do
    c1 = Citation.create(citation_object: o1, source:, pages: 123)
    c2 = Citation.create(citation_object: o1, source:, pages: 456)

    o1.unify(o2)

    expect(o1.citations.reload.count).to eq(2)
    expect(o1.citations.last.pages).to eq("456")
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
    ad1 = FactoryBot.create(:valid_asserted_distribution, otu: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, otu: o2, geographic_area: ad1.geographic_area)

    ad2.otu = o1

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
    ad1 = FactoryBot.create(:valid_asserted_distribution, otu: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, otu: o2, geographic_area: ad1.geographic_area) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2)

    expect(AssertedDistribution.find_by(id: ad2.id)).to eq(nil)
    expect(n.reload.note_object).to eq(ad1)
    expect(o2.destroyed?).to be_truthy
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

    ad1 = FactoryBot.create(:valid_asserted_distribution, otu: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, otu: o2, geographic_area: ad1.geographic_area, source: s)

    expect(Citation.all.size).to eq(2)

    b = o1.unify(o2)

    expect(o2.destroyed?).to be_truthy
    expect(Citation.all.size).to eq(1)
  end

end

class TestUnify < ApplicationRecord
  include FakeTable
  include Shared::Unify
end

