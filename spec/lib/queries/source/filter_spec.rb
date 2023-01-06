require 'rails_helper'
require_relative "shared_context"

describe Queries::Source::Filter, type: :model, group: [:sources, :filter] do

  # lib/queries/source/shared_context.rb
  include_examples 'source queries'

  let(:query) {  Queries::Source::Filter.new({})  }
  let!(:doi) { '10.11646/stuff.1234.5.6' }
  let(:tomorrow) {  (Time.now + 1.day).strftime("%Y-%m-%d") }

  specify '#cached ordered fragments' do
    s = FactoryBot.create(:valid_source_verbatim, verbatim: 'Jones, AP (1920) stuff and things')
    query.query_string = 'Jones 1920'
    expect(query.all.map(&:id)).to contain_exactly(s.id)
  end

  specify '#ancestor_id' do
    t = FactoryBot.create(:valid_taxon_name)
    c = FactoryBot.create(:valid_citation, citation_object: t)
    query.ancestor_id = t.id
    expect(query.all.map(&:id)).to contain_exactly( c.source.id)
  end

  specify '#ancestor_id, omits in scope sources on OTUs' do
    t = FactoryBot.create(:valid_taxon_name)
    c = FactoryBot.create(:valid_citation, citation_object: t)

    c2 = FactoryBot.create(:valid_citation, citation_object: FactoryBot.create(:valid_descriptor))
    c3 = FactoryBot.create(:valid_citation, citation_object: FactoryBot.create(:valid_otu, taxon_name: t))

    query.ancestor_id = t.id
    expect(query.all.map(&:id)).to contain_exactly( c.source.id)
  end

  specify '#ancestor_id, includes TaxonNameClassifications' do
    t = FactoryBot.create(:valid_taxon_name)
    c = FactoryBot.create(:valid_citation, citation_object: t)

    c1 = FactoryBot.create(:valid_citation, citation_object: FactoryBot.create(:valid_taxon_name_classification, taxon_name: t))

    query.ancestor_id = t.id
    expect(query.all.map(&:id)).to contain_exactly( c.source.id, c1.source.id)
  end

  specify '#citations_on_otus' do
    o = Otu.create!(taxon_name: FactoryBot.create(:valid_taxon_name))
    c = FactoryBot.create(:valid_citation, citation_object: o)

    FactoryBot.create(:valid_citation, citation_object: Otu.create!(name: 'ancestor no'))

    query.citations_on_otus = true
    query.ancestor_id = o.taxon_name_id

    expect(query.all.map(&:id)).to contain_exactly(c.source.id)
  end

  specify '#citations_on_otus (and taxon names)' do
    o = Otu.create!(taxon_name: FactoryBot.create(:valid_taxon_name))
    c1 = FactoryBot.create(:valid_citation, citation_object: o)

    c2 = FactoryBot.create(:valid_citation, citation_object: o.taxon_name)

    query.citations_on_otus = true
    query.ancestor_id = o.taxon_name_id

    expect(query.all.map(&:id)).to contain_exactly(c1.source.id, c2.source.id )
  end

  specify '#source_type' do
    query.source_type = 'Source::Verbatim'
    expect(query.all.map(&:id)).to contain_exactly( s1.id, s6.id )
  end

  # Duplicate f() with collection objects
  # Should be in identifiers concern specs ...
  specify '#identifier' do
    i = Identifier::Global::Doi.create!(identifier_object: s1, identifier: doi )
    query.identifier = doi
    query.identifier_exact = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#namespace_id' do
    i = Identifier::Local::Import.create!(namespace: FactoryBot.create(:valid_namespace), identifier: '123', identifier_object: s1)
    query.namespace_id = i.namespace.id
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end
  # end should be in identifiers concern


  specify '#with_note 1' do
    Note.create!(text: 'my note', note_object: s1)
    query.notes = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#with_note 2' do
    Note.create!(text: 'test', note_object: s1)
    Note.create!(text: 'tube', note_object: s1)
    query.notes = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#with_note 3 (without notes)' do
    query.notes = false
    expect(query.all.map(&:id)).to contain_exactly(*all_source_ids)
  end

  specify '#with_tag 1' do
    Tag.create!(keyword: FactoryBot.create(:valid_keyword), tag_object: s1)
    query.tags = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#with_tag 1 (distinct)' do
    Tag.create!(keyword: FactoryBot.create(:valid_keyword), tag_object: s1)
    Tag.create!(keyword: FactoryBot.create(:valid_keyword), tag_object: s1)
    query.tags = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#citation_object_type 1' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name))
    query.citation_object_type = ['TaxonName']
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#citation_object_type 2' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name))
    query.citation_object_type = ['Specimen']
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#topic_ids 1' do
    topic = FactoryBot.create(:valid_topic)
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name), topics: [topic])
    query.topic_ids = [topic.id]
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#topic_ids 2' do
    t1 = FactoryBot.create(:valid_topic)
    t2 = FactoryBot.create(:valid_topic)
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name), topics: [t1])
    query.topic_ids = [t2.id]
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#topic_ids 3' do
    topic = FactoryBot.create(:valid_topic)
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name), topics: [topic])
    expect(query.all.map(&:id)).to_not contain_exactly()
  end

  specify '#with_doi 1' do
    Identifier::Global::Doi.create!(identifier_object: s1, identifier: doi)
    query.with_doi = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#with_doi 2' do
    Identifier::Global::Doi.create!(identifier_object: s2, identifier: doi)
    query.with_doi = false
    expect(query.all.map(&:id)).to contain_exactly( *all_source_ids - [s2.id] )
  end

  specify '#nomenclature 1' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name))
    query.nomenclature = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#nomenclature 2' do
    a = Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name)) # dummy citation
    query.nomenclature = false
    expect(query.all.map(&:id)).to contain_exactly( *(all_source_ids - [s1.id]) )
  end

  specify '#documents 1' do
    FactoryBot.create(:valid_documentation, documentation_object: s1)
    query.documents = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#documents 2' do
    query.documents = false
    expect(query.all.map(&:id)).to contain_exactly( *all_source_ids )
  end

  specify '#roles 1' do
    query.roles = true
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s4.id)
  end

  specify '#roles 2' do
    query.roles = false
    expect(query.all.map(&:id)).to contain_exactly( *(all_source_ids - [s2.id, s4.id]) )
  end

  specify '#citations 1' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:valid_otu))
    query.citations = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#citations 2' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:valid_otu))
    query.citations = false
    expect(query.all.map(&:id)).to contain_exactly( *(all_source_ids - [s1.id]) )
  end

  specify '#title, #exact_title 1' do
    query.title = 'Creatures from the Black Lagoon.'
    query.exact_title = true
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#title, #exact_title 2 (whitespace ignored)' do
    query.title = "Creatures from \n the Black Lagoon."
    query.exact_title = true
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#title, #exact_title 3 (whitespace ignored)' do
    query.title = "Creatures from the Black Lagoon. "
    query.exact_title = true
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#title, #exact_title 4 (whitespace ignored)' do
    query.title = " \nCreatures from the Black Lagoon."
    query.exact_title = true
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#title, #exact_title 5 (whitespace ignored)' do
    query.title = "Creatures from      the Black Lagoon.\n\n "
    query.exact_title = true
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#title' do
    query.title = 'Creatures'
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#year_start' do
    query.year_start = 1940
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#year_end' do
    query.year_start = 1921
    query.year_end = 1940
    expect(query.all.map(&:id)).to contain_exactly(s3.id, s4.id, s5.id)
  end

  specify '#author_ids' do
    query.author_ids = [p1.id]
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s4.id)
  end

  specify '#exact_author' do
    query.author = 'Smith'
    query.exact_author = true
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s3.id)
  end

  specify '#author' do
    query.author = 'Smit'
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s3.id, s4.id)
  end

  specify '#project_id / in_project 1' do
    query.project_id = Current.project_id
    query.in_project = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#project_id / in_project 1' do
    ProjectSource.create!(source: s1, project_id: Current.project_id)
    query.project_id = Current.project_id
    query.in_project = false
    expect(query.all.map(&:id)).to contain_exactly( *(all_source_ids - [s1.id]) )
  end

  specify '#project_id / in_project 2' do
    query.project_id = Current.project_id
    query.in_project = false
    expect(query.all.map(&:id)).to contain_exactly(*all_source_ids)
  end

  specify '#project_id / in_project 3' do
    ProjectSource.create!(source: s1, project_id: Current.project_id)
    ProjectSource.create!(source: s2, project_id: FactoryBot.create(:valid_project).id)
    query.project_id = Current.project_id
    query.in_project = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#query_term' do
    q = Queries::Source::Filter.new(query_term: 'Unintelligible')

    expect(q.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#query_string' do
    query.query_string = 'Unintelligible'
    expect(query.terms).to contain_exactly('Unintelligible%', '%Unintelligible%')
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  context 'all' do
    before do
      query.user_id = Current.user_id
      query.user_target = 'created'
      query.user_date_start = '2001-1-2'
      query.user_date_end = tomorrow
      query.documents = true
      query.in_project = true
    end

    specify 'vanilla' do
      expect(query.all.map(&:id)).to contain_exactly()
    end

    specify 'pagination' do
      expect(query.all.page(1).per(1).map(&:id)).to contain_exactly()
    end

    specify 'order' do
      q = query.all.order(:cached)
      expect(q.map(&:id)).to contain_exactly()
    end
  end

  # 
  # Specs covering lib/queries/concerns/tags.rb
  #

  context 'keyword_id' do
    specify '#keyword_id_and' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_and = [t1.keyword_id, t2.keyword_id]
      expect(query.matching_keyword_id_and.map(&:id)).to contain_exactly(s1.id)
    end

    specify '#keyword_id_or' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_or = [t1.keyword_id, t2.keyword_id]
      expect(query.matching_keyword_id_or.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

    specify '#keyword_id_or, #keyword_id_and 1' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))

      t3 = Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword))

      # not this
      t4 = Tag.create!(tag_object: s3, keyword: t1.keyword)

      query.keyword_id_and = [t1.keyword_id, t2.keyword_id]
      query.keyword_id_or = [t3.keyword_id]

      expect(query.all.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

    specify '#keyword_id_or, #keyword_id_and 2 (one AND is an OR)' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword))

      # not this
      t3 = Tag.create!(tag_object: s3, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_and = [t1.keyword_id]
      query.keyword_id_or = [t2.keyword_id]

      expect(query.all.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

  end

end
