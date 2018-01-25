require 'rails_helper'

describe Citation, type: :model, group: [:annotators, :citations] do
  let(:citation) { Citation.new }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }
  let(:topic) { FactoryBot.create(:valid_topic) }

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

  context 'validation' do
    let!(:c1) { Citation.create!(citation_object: otu, source: source) }
    let(:c2) { Citation.new( citation_object: otu, source: source)  }
    let(:c3) { Citation.new() }

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
