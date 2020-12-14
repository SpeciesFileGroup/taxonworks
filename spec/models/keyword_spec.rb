require 'rails_helper'

describe Keyword, type: :model, group: :tags do
  
  let(:keyword) { Keyword.new } 
  let(:otu) { FactoryBot.create(:valid_otu) }

  specify '#tags' do
    expect(keyword.tags << Tag.new(tag_object: otu) ).to be_truthy
  end

  context 'validation' do
    let!(:k) { FactoryBot.create(:valid_keyword) }

    specify 'can be used for tags' do
      t = Tag.new(keyword: k, tag_object: FactoryBot.build(:valid_otu))
      expect(t.save).to be_truthy
    end

    specify 'can not be used for other things' do
      expect {c = CitationTopic.new(topic: k)}.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end
  end
  
  context 'scopes' do
    let(:k) { FactoryBot.create(:valid_keyword) }
    let(:k2) { FactoryBot.create(:valid_keyword) }
    let!(:tag) { Tag.create(keyword: k, tag_object: otu) } 
    let!(:old_tag) { Tag.create(keyword: k2, tag_object: otu, created_at: 4.years.ago) } 

    specify '#used_on_klass 1' do
      expect(Keyword.used_on_klass('Otu')).to contain_exactly(k, k2)
    end

    specify '#used_on_klass 2' do
      expect(Keyword.used_on_klass('CollectionObject')).to contain_exactly()
    end

    specify '#used_on_klass.used_recently' do
      expect(Keyword.used_recently(k.created_by_id, k.project_id, 'Otu')).to contain_exactly(k.id)
    end
  end

  specify 'tagged_objects' do
    expect(keyword).to respond_to(:tagged_objects)
    k = FactoryBot.create(:valid_keyword)
    t1 = Tag.create(keyword: k, tag_object: FactoryBot.create(:valid_otu))
    t2 = Tag.create(keyword: k, tag_object: FactoryBot.create(:valid_specimen))
    expect(k.tagged_objects.count).to eq(2)
    expect(k.tags.count).to eq(2)
  end

  specify 'tagged_object_class_names' do
    expect(keyword).to respond_to(:tagged_object_class_names)
    k = FactoryBot.create(:valid_keyword)
    t1 = Tag.create(keyword: k, tag_object: FactoryBot.create(:valid_otu))
    expect(k.tagged_object_class_names).to eq(%w{Otu})

  end



end

