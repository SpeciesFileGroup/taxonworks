require 'rails_helper'

describe Queries::Content::Filter, type: :model do

  let(:t1) { FactoryBot.create(:valid_topic) } 
  let(:t2) { FactoryBot.create(:valid_topic) } 
  let(:t3) { FactoryBot.create(:valid_topic) } 

  let(:o1) { Otu.create!(name: 'T1') }
  let(:o2) { Otu.create!(name: 'T2') }

  let!(:c1) { Content.create!(otu: o1, text: 'text 1 stuff', topic: t1) } 
  let!(:c2) { Content.create!(otu: o2, text: 'text 2 things', topic: t2) } 
  let!(:c3) { Content.create!(otu: o2, text: 'text 3 stuf', topic: t3) } 

  let(:query) { Queries::Content::Filter.new({}) }

  specify 'topic_id Integer' do
    query.topic_id = t1.id
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify 'topic_id Array' do
    query.topic_id = [t2.id]
    expect(query.all.map(&:id)).to contain_exactly(c2.id)
  end

  specify 'otu Integer' do
    query.otu_id = o2.id
    expect(query.all.map(&:id)).to contain_exactly(c2.id, c3.id)
  end

  specify 'otu Array' do
    query.otu_id = [o2.id]
    expect(query.all.map(&:id)).to contain_exactly(c2.id, c3.id)
  end

  specify 'text' do
    query.text = 'stuf'
    expect(query.all.map(&:id)).to contain_exactly(c1.id, c3.id)
  end

  specify 'text, exact' do
    query.text = c1.text
    query.exact = true 
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify 'depictions 1' do
    c1.depictions << Depiction.new(image: FactoryBot.create(:valid_image))
    query.depictions = true
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify 'depictions 2' do
    c1.depictions << Depiction.new(image: FactoryBot.create(:valid_image))
    query.depictions = false 
    expect(query.all.map(&:id)).to contain_exactly(c2.id, c3.id)
  end

  specify 'citations 1' do
    c1.citations << Citation.new(source: FactoryBot.create(:valid_source))
    query.citations = true
    expect(query.all.map(&:id)).to contain_exactly(c1.id)
  end

  specify 'citations 2' do
    c1.citations << Citation.new(source: FactoryBot.create(:valid_source))
    query.citations = false 
    expect(query.all.map(&:id)).to contain_exactly(c2.id, c3.id)
  end

  specify 'project_id' do
    query.project_id = 999999
    expect(query.all.map(&:id)).to contain_exactly()
  end



end
