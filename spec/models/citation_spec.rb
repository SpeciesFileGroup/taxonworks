require 'rails_helper'

describe Citation, type: :model, group: [:annotators, :citations] do
  let(:citation) { Citation.new }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }
  let(:topic) { FactoryBot.create(:valid_topic) }

  let(:pdf) { fixture_file_upload( Spec::Support::Utilities::Files.generate_pdf(pages: 10) ) } 

  context 'page links' do
    let!(:document) { Document.create!( document_file: fixture_file_upload( fixture_file_upload( pdf, 'application/pdf')),
                                       initialize_start_page: 10
                                      ) } 

    let!(:documentation) { Documentation.create!(documentation_object: source, document: document) }

    before do
      citation.citation_object = otu
      citation.source = source
      citation.pages = '99'
      citation.save
    end

    specify '#first_page 1' do
      citation.pages = '99'
      expect(citation.first_page).to eq('99')
    end

    specify '#first_page 2' do
      citation.pages = '22, 99'
      expect(citation.first_page).to eq('22')
    end

    specify '#first_page 3' do
      citation.pages = '2-44, ix'
      expect(citation.first_page).to eq('2')
    end

    specify '#target_document' do
      expect(citation.target_document).to eq(document)
    end

    specify '#target_document_page 1' do
      citation.pages = '15'
      expect(citation.target_document_page).to eq('6')
    end

    specify '#target_document_page 2' do
      citation.pages = '99'
      expect(citation.target_document_page).to eq(nil)
    end

  end

  context 'associations' do
    context 'belongs_to' do
      specify '#citation_object' do
        expect(citation.citation_object = Otu.new).to be_truthy
      end

      specify '#source' do
        expect(citation.source = Source.new).to be_truthy
      end
    end
  end

  context 'soft validation' do
    let!(:c1) { Citation.create!(citation_object: otu, source: source) }

    specify 'no pages' do
      c1.pages = nil
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages)).to include('Citation pages are not provided')
    end

    specify 'one page in range 1' do
      c1.pages = '25'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages).empty?).to be_truthy
    end

    specify 'one page in range 2' do
      c1.pages = '25-26'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages).empty?).to be_truthy
    end

    specify 'page in out of range 1' do
      c1.pages = '55'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages)).to include('Citation is out of the source page range')
    end

    specify 'page in out of range 2' do
      c1.pages = '15'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages)).to include('Citation is out of the source page range')
    end

    specify 'page in out of range 3' do
      c1.pages = '15-25'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages)).to include('Citation is out of the source page range')
    end

    specify 'page in out of range 4' do
      c1.pages = '25-55'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages)).to include('Citation is out of the source page range')
    end

    specify 'page in out of range 5' do
      c1.pages = '15-55'
      source.pages = '20-30'
      c1.soft_validate(only_sets: :page_range)
      expect(c1.soft_validations.messages_on(:pages)).to include('Citation is out of the source page range')
    end
  end

  context 'validation' do
    let!(:c1) { Citation.create!(citation_object: otu, source: source) }
    let(:c2) { Citation.new( citation_object: otu, source: source)  }
    let(:c3) { Citation.new() }

    specify 'one is_original per citation_object' do
      c1.update(is_original: true)
      c2.is_original = true
      expect(c2.valid?).to be_falsey
      expect(c2.errors[:is_original]).to be_truthy
    end

    specify 'many is_original is false per citation_object' do
      c1.update(is_original: false)
      c2.is_original = false
      expect(c1.valid?).to be_truthy
      expect(c2.errors[:is_original].empty?).to be_truthy
    end

    specify 'exact duplicates are invalid' do
      expect(c2.valid?).to be_falsey
    end

    specify 'errors are added to source' do
      c2.valid?
      expect(c2.errors.messages[:source_id]).to include('has already been taken')
    end

    specify 'empty pages are null, and therefor not unique' do
      expect(Citation.create(citation_object: otu, source: source, pages: '').id).to be_falsey
    end

    specify 'finding by nil will find records created with nil' do
      expect(Citation.find_or_create_by(citation_object: otu, source: source, pages: nil)).to eq(c1)
    end

    specify 'finding by pages: "" will always create a new record' do
      expect(Citation.find_or_create_by(citation_object: otu, source: source, pages: '').new_record?).to be_truthy
    end

    specify '#citation_object_id is required by database' do
      c3.source = source
        c3.citation_object_type = 'Otu'
        expect{c3.save}.to raise_error(ActiveRecord::StatementInvalid)
      end

    specify '#citation_object_type is required by database' do
      c3.source = source
      c3.citation_object_id = otu.id
        expect{c3.save}.to raise_error(ActiveRecord::StatementInvalid)
      end

    specify 'source_id is required' do
      c3.citation_object = otu

      expect(c3.valid?).to be_falsey
      expect(c3.errors.messages[:source_id]).to include("can't be blank")
    end
  end

  specify '#citation_topic_attributes 1' do
    expect(Citation.create(citation_object: otu, source: source, citation_topics_attributes: [{topic: topic}])).to be_truthy
    expect(CitationTopic.count).to eq(1)
  end

  specify '#citation_topic_attributes 2' do
    expect(Citation.create(citation_object: otu, source: source, citation_topics_attributes: [{topic_id: topic.id}])).to be_truthy
    expect(CitationTopic.count).to eq(1)
  end

  specify '<< and citation_topics_attributes' do
    otu.citations << Citation.new(source: source, citation_topics_attributes: [{topic: topic}])
    expect(otu.topics.all).to include(topic)
  end

  specify 'creating a new citation rejects citation_topic when topic not provided' do
    expect(otu.citations << Citation.new(source: source, citation_topics_attributes: [{pages: '123'}])).to be_truthy
    expect(otu.topics.count).to eq(0)
  end

  specify '#topics_attributes' do
    otu.citations << Citation.new(source: source, topics_attributes: [{name: 'Special topics', definition: 'This is a really long definition, really!'}])
    expect(Topic.count).to eq(1)
    expect(CitationTopic.count).to eq(1)
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
