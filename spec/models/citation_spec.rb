require 'rails_helper'

describe Citation, type: :model, group: [:annotators, :citations] do
  let(:citation) { FactoryBot.build(:citation) }

  context 'associations' do
    context 'belongs_to' do

      specify 'citation_object' do
        expect(citation).to respond_to(:citation_object)
      end

      specify 'source' do
        expect(citation).to respond_to(:source)
      end
    end
  end

  context 'validation' do
    let(:o) { FactoryBot.create(:valid_otu) }
    let(:s) { FactoryBot.create(:valid_source) }
    let(:c1) { FactoryBot.create(:valid_citation, {citation_object: o, source: s}) }
    let(:c2) { FactoryBot.build(:valid_citation, citation_object: o, source: s) }
    let(:c3) { FactoryBot.build(:citation) }

    specify 'uniqueness' do
      expect(c1.valid?).to be_truthy
      expect(c2.valid?).to be_falsey
      expect(c2.errors.messages[:source_id][0]).to eq('has already been taken')
    end

    specify 'validate uniqueness of pages with nil and empty string. Nullify before save.' do
      expect(Citation.count).to eq(0) 
      expect(Citation.create(citation_object: o, source: s, pages: '').id).to be_truthy
      expect(Citation.create(citation_object: o, source: s, pages: nil).id).to be_falsey
      expect(Citation.find_or_create_by(citation_object: o, source: s, pages: nil).id).to eq(Citation.first.id)
    end

    context 'database constraints' do
      before { c3.source = s }

      specify 'citation_object_id is required by database' do
        c3.citation_object_type = 'Otu'
        expect{c3.save}.to raise_error(ActiveRecord::StatementInvalid) 
      end

      specify 'citation_object_type is required by database' do
        c3.citation_object_id = o.id 
        expect{c3.save}.to raise_error(ActiveRecord::StatementInvalid) 
      end
    end

    specify 'source_id is required' do
      c3.citation_object = o
      expect(c3.valid?).to be_falsey
      expect(c3.errors.messages[:source_id][0]).to eq("can't be blank")
    end
  end

  context 'with a Topic created' do
    let(:ct) { FactoryBot.create(:valid_citation_topic) }
    let(:o) { FactoryBot.create(:valid_otu) }
    let(:s) { FactoryBot.create(:valid_source_bibtex) }
    let(:c1) { FactoryBot.create(:valid_citation, {citation_object: o,
                                                    source:          s,
                                                    citation_topics: [ct]}) }
    let(:t) { FactoryBot.create(:valid_topic) }


    context 'nested attribute passed during create' do
      specify 'on save' do
        expect(c1.save).to be_truthy
        expect(c1.citation_topics.size).to eq(1)
      end
    end

    specify 'create a new citation with a citation_topic through nested attributes' do
      o.citations << Citation.new(source: s, citation_topics_attributes: [ {topic: t} ])
      expect(o.topics.all).to include(t) 
    end

    specify 'creating a new citation rejects citation_topic when topic not provided' do
      expect(o.citations << Citation.new(source: s, citation_topics_attributes: [ {pages: '123'} ])).to be_truthy
      expect(o.topics.count).to eq(0)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
