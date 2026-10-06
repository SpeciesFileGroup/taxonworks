require 'rails_helper'

# Annotation filters (Citation, Tag, Note, ...) passed as a subquery to the
# filter of an annotated model return the annotated records.
describe Queries::Query::Filter, type: :model do

  let(:keyword) { FactoryBot.create(:valid_keyword) }

  specify 'Otu filter with citation_query returns the cited Otus' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)
    FactoryBot.create(:valid_otu)
    c1 = FactoryBot.create(:valid_citation, citation_object: o1)
    FactoryBot.create(:valid_citation, citation_object: o2)

    q = Queries::Otu::Filter.new(citation_query: { citation_id: [c1.id] })
    expect(q.all).to contain_exactly(o1)
  end

  specify 'citation_query only returns records of the filter model' do
    o = FactoryBot.create(:valid_otu)
    tn = FactoryBot.create(:valid_protonym)
    c = FactoryBot.create(:valid_citation, citation_object: tn)
    FactoryBot.create(:valid_citation, citation_object: o)

    q = Queries::Otu::Filter.new(citation_query: { citation_id: [c.id] })
    expect(q.all).to be_empty
  end

  specify 'TaxonName filter with note_query returns noted TaxonNames (STI)' do
    tn1 = FactoryBot.create(:valid_protonym)
    tn2 = FactoryBot.create(:valid_protonym)
    Note.create!(note_object: tn1, text: 'find me')
    Note.create!(note_object: tn2, text: 'not this one')

    q = Queries::TaxonName::Filter.new(note_query: { text: 'find' })
    expect(q.all).to contain_exactly(tn1)
  end

  specify 'CollectionObject filter with tag_query returns tagged CollectionObjects' do
    s1 = FactoryBot.create(:valid_specimen)
    s2 = FactoryBot.create(:valid_specimen)
    Tag.create!(tag_object: s1, keyword:)
    Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword)) # tagged, but not with keyword

    q = Queries::CollectionObject::Filter.new(tag_query: { keyword_id: [keyword.id] })
    expect(q.all).to contain_exactly(s1)
  end

  specify 'Image filter with identifier_query returns identified Images' do
    i1 = FactoryBot.create(:tiny_random_image)
    i2 = FactoryBot.create(:tiny_random_image)
    id = Identifier::Global::Uri.create!(identifier_object: i1, identifier: 'https://example.org/image/1')
    Identifier::Global::Uri.create!(identifier_object: i2, identifier: 'https://example.org/image/2') # identified, but not by id

    q = Queries::Image::Filter.new(identifier_query: { identifier_id: [id.id] })
    expect(q.all).to contain_exactly(i1)
  end

  specify 'Descriptor filter with alternate_value_query returns Descriptors with that alternate value' do
    d1 = FactoryBot.create(:valid_descriptor)
    d2 = FactoryBot.create(:valid_descriptor)
    AlternateValue::Abbreviation.create!(alternate_value_object: d1, alternate_value_object_attribute: 'name', value: 'abbr1')
    AlternateValue::Abbreviation.create!(alternate_value_object: d2, alternate_value_object_attribute: 'name', value: 'abbr2')

    q = Queries::Descriptor::Filter.new(alternate_value_query: { value: 'abbr1' })
    expect(q.all.pluck(:id)).to contain_exactly(d1.id)
  end

  # The radial filter sends checked rows as <annotator>_id inside the nested query
  specify 'checked Tag rows (tag_id) survive nested param permitting' do
    s1 = FactoryBot.create(:valid_specimen)
    s2 = FactoryBot.create(:valid_specimen)
    t1 = Tag.create!(tag_object: s1, keyword:)
    Tag.create!(tag_object: s2, keyword:)

    p = ActionController::Parameters.new(tag_query: { tag_id: [t1.id] })
    q = Queries::CollectionObject::Filter.new(p)
    expect(q.all).to contain_exactly(s1)
  end


  specify 'checked Citation rows (citation_id) survive nested param permitting' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)
    c1 = FactoryBot.create(:valid_citation, citation_object: o1)
    FactoryBot.create(:valid_citation, citation_object: o2)

    p = ActionController::Parameters.new(citation_query: { citation_id: [c1.id] })
    q = Queries::Otu::Filter.new(p)
    expect(q.all).to contain_exactly(o1)
  end

end
