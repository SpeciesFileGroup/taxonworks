require 'rails_helper'

describe Queries::Citation::Filter, type: :model do

  let(:query) { Queries::Citation::Filter.new({}) }

  specify '#citation_object_type, #citation_object_id' do
    p = ActionController::Parameters.new(collecting_event_id: 1 )
    o = FactoryBot.create(:valid_otu)
    o.citations << Citation.new(source: FactoryBot.create(:valid_source))

    FactoryBot.create(:valid_citation) # not this one

    query.citation_object_type = 'Otu'
    query.citation_object_id = o.id

    expect(query.all).to contain_exactly(o.citations.first)
  end

  specify '#polymorphic_id_facet 1' do
    p = ActionController::Parameters.new(collecting_event_id: 1 )
    q = Queries::Citation::Filter.new(p)
    expect(q.all.to_sql).to eq("SELECT \"citations\".* FROM \"citations\" WHERE \"citations\".\"citation_object_id\" = 1 AND \"citations\".\"citation_object_type\" = 'CollectingEvent' AND \"citations\".\"project_id\" IN (1)")
  end

  # foo is ignored
  specify '#polymorphic_id_facet 2' do
    p = ActionController::Parameters.new(collecting_event_id: 1, foo: 1 )
    q = Queries::Citation::Filter.new(p)
    expect(q.all.to_sql).to eq("SELECT \"citations\".* FROM \"citations\" WHERE \"citations\".\"citation_object_id\" = 1 AND \"citations\".\"citation_object_type\" = 'CollectingEvent' AND \"citations\".\"project_id\" IN (1)")
  end

  specify '#is_original' do
    original = FactoryBot.create(:valid_citation, is_original: true)
    FactoryBot.create(:valid_citation, is_original: nil)

    query.is_original = true
    expect(query.all).to contain_exactly(original)
  end

  context 'topic facets' do
    let!(:topic) { FactoryBot.create(:valid_topic) }
    let!(:other_topic) { FactoryBot.create(:valid_topic) }
    let!(:c_with_topic) {
      c = FactoryBot.create(:valid_citation)
      CitationTopic.create!(citation: c, topic:, pages: '1-10')
      c
    }
    let!(:c_with_other_topic) {
      c = FactoryBot.create(:valid_citation)
      CitationTopic.create!(citation: c, topic: other_topic, pages: '20')
      c
    }
    let!(:c_no_topic) { FactoryBot.create(:valid_citation) }

    specify '#topic_id matches a single topic' do
      query.topic_id = topic.id
      expect(query.all).to contain_exactly(c_with_topic)
    end

    specify '#topic_id matches multiple topics' do
      query.topic_id = [topic.id, other_topic.id]
      expect(query.all).to contain_exactly(c_with_topic, c_with_other_topic)
    end

    specify '#citation_topics true returns citations that have any citation_topic' do
      q = Queries::Citation::Filter.new(citation_topics: true)
      expect(q.all).to contain_exactly(c_with_topic, c_with_other_topic)
    end

    specify '#citation_topics false returns citations that have none' do
      q = Queries::Citation::Filter.new(citation_topics: false)
      expect(q.all).to contain_exactly(c_no_topic)
    end

    specify '#citation_topic_pages matches with wildcard' do
      query.citation_topic_pages = '1-1'
      expect(query.all).to contain_exactly(c_with_topic)
    end

    specify '#citation_topic_pages_exact requires an exact pages match' do
      query.citation_topic_pages = '20'
      query.citation_topic_pages_exact = true
      expect(query.all).to contain_exactly(c_with_other_topic)
    end
  end

  context '#source_documents' do
    let!(:c_with_docs) {
      c = FactoryBot.create(:valid_citation)
      FactoryBot.create(:valid_documentation, documentation_object: c.source)
      c
    }
    let!(:c_no_docs) { FactoryBot.create(:valid_citation) }

    specify 'true returns citations whose source has documentation' do
      query.source_documents = true
      expect(query.all).to contain_exactly(c_with_docs)
    end

    specify 'false returns citations whose source has no documentation' do
      query.source_documents = false
      expect(query.all).to contain_exactly(c_no_docs)
    end
  end

  context 'subquery facets' do
    specify '#taxon_name_query matches citations annotating TaxonNames in the subquery' do
      tn = FactoryBot.create(:valid_protonym)
      other_tn = FactoryBot.create(:valid_protonym)

      on_tn = FactoryBot.create(:valid_citation, citation_object: tn)
      FactoryBot.create(:valid_citation, citation_object: other_tn) # not this one
      FactoryBot.create(:valid_citation) # default citation_object is Otu, not this one

      p = ActionController::Parameters.new(taxon_name_query: { taxon_name_id: [tn.id] })
      q = Queries::Citation::Filter.new(p)
      expect(q.all).to contain_exactly(on_tn)
    end

    specify '#source_query matches citations whose source is in the source subquery' do
      source = FactoryBot.create(:valid_source_bibtex)
      cited_with_source = FactoryBot.create(:valid_citation, source:)
      FactoryBot.create(:valid_citation) # different source

      p = ActionController::Parameters.new(source_query: { source_id: [source.id] })
      q = Queries::Citation::Filter.new(p)
      expect(q.all).to contain_exactly(cited_with_source)
    end
  end
end
