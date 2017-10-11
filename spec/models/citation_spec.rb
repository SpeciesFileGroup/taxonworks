require 'rails_helper'

describe Citation, type: :model, group: [:annotators, :citations] do
  let(:citation) { FactoryGirl.build(:citation) }

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
    let(:o) { FactoryGirl.create(:valid_otu) }
    let(:s) { FactoryGirl.create(:valid_source) }
    let(:c1) { FactoryGirl.create(:valid_citation, {citation_object: o, source: s}) }
    let(:c2) { FactoryGirl.build(:valid_citation, citation_object: o, source: s) }
    let(:c3) { FactoryGirl.build(:citation) }

    specify 'uniqueness' do
      expect(c1.valid?).to be_truthy
      expect(c2.valid?).to be_falsey
      expect(c2.errors.messages[:source_id][0]).to eq('has already been taken')
    end

    context 'uniqueness of citation takes into account pages' do
      before { 
        Citation.create!(citation_object: o, source: s, pages: '')
      } 

      specify 'empty quotes are converted to nil, therefor the same' do
        expect(Citation.create(citation_object: o, source: s, pages: nil).id).to be_falsey
      end

      specify 'finding by nil will find records created with ""' do
        expect(Citation.find_or_create_by(citation_object: o, source: s, pages: nil).id).to eq(Citation.first.id)
      end
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
    let(:ct) { FactoryGirl.create(:valid_citation_topic) }
    let(:o) { FactoryGirl.create(:valid_otu) }
    let(:s) { FactoryGirl.create(:valid_source_bibtex) }
    let(:c1) { FactoryGirl.create(:valid_citation, {citation_object: o,
                                                    source:          s,
                                                    citation_topics: [ct]}) }
    let(:t) { FactoryGirl.create(:valid_topic) }


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
