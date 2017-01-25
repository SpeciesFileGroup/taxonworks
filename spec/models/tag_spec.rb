require 'rails_helper'

describe Tag, type: :model, group: [:annotators, :tags] do

  let(:tag) { Tag.new }
  let(:keyword) { FactoryGirl.create(:valid_keyword) }
  let(:otu) { FactoryGirl.create(:valid_otu) }

  context 'associations' do
    specify 'tag_object' do 
      expect(tag.tag_object = FactoryGirl.create(:valid_biocuration_class)).to be_truthy
    end

    specify 'keyword' do
      expect(tag.keyword = FactoryGirl.create(:valid_keyword)).to be_truthy
    end
  end

  context 'validation' do
    before(:each) do
      tag.valid?
    end

    specify 'a keyword is required' do
      expect(tag.errors.include?(:keyword)).to be_truthy
    end

    specify 'a topic can not be used' do
      t = Topic.new(name: 'foo', definition: 'Something about foo')
      expect{tag.keyword = t}.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    specify 'a tagged object is only tagged once per keyword' do
      b = FactoryGirl.build(:valid_otu)
      k = FactoryGirl.create(:valid_keyword)
      tag.tag_object = b
      tag.keyword = k
      tag.valid?
      expect(tag.errors.include?(:keyword)).to be_falsey
      expect(tag.errors.include?(:tag_object)).to be_falsey
      tag.save!
      dupe_tag = FactoryGirl.build(:tag, keyword: k, tag_object: b) 
      dupe_tag.valid?
      expect(dupe_tag.errors.include?(:keyword_id)).to be_truthy
    end

   specify 'keywords scope can be limited with Keyword#can_tag' do
     a = FactoryGirl.create(:valid_biocuration_group)
     b = FactoryGirl.create(:valid_specimen)
     t = Tag.new(tag_object: b, keyword: a)
     expect(t.valid?).to be_falsey
     expect(t.errors.include?(:keyword)).to be_truthy
   end

    specify 'tag_object class can be limited with TagObject#taggable_with' do
      a = FactoryGirl.create(:valid_keyword)
      b = FactoryGirl.create(:valid_biocuration_class)
      t = Tag.new(tag_object: b, keyword: a)
      expect(t.valid?).to be_falsey
      expect(t.errors.include?(:tag_object)).to be_truthy
    end

    context 'STI based tag behaviour' do
      before(:each) {
        tag.keyword = FactoryGirl.create(:valid_keyword) 
        tag.tag_object = FactoryGirl.create(:valid_specimen)
      }

      specify 'tagging an subclass of an STI model instance *stores* the tag_type as the superclass' do
        expect(tag.save).to be_truthy
        expect(tag.tag_object_type).to eq('CollectionObject')
      end

      specify 'tagging an subclass of an STI model instance, with subclass namespace, *stores* the tag_type as the superclass' do
        tag.tag_object = FactoryGirl.create(:valid_container_box)
        expect(tag.save).to be_truthy
        expect(tag.tag_object_type).to eq('Container')
      end

      specify 'tagging a subclass of an STI model *returns* the subclassed object' do
        expect(tag.save).to be_truthy
        expect(tag.tag_object.class).to eq(Specimen) 
      end
    end

    context 'acts_as_list' do
      specify 'position is set' do
        t1 = FactoryGirl.create(:valid_tag)
        expect(t1.position).to eq(1)
      end
    end

    context 'global ids/entity' do
      before {
        tag.tag_object_global_entity = otu.to_global_id
        tag.keyword = keyword
        tag.save!
      }
      
      specify 'tag_object can be set by global_id' do
        expect(tag.tag_object).to eq(otu)
      end

      specify 'tag_object_global_entity can be returned' do
        expect(tag.tag_object_global_entity).to eq(otu.to_global_id)
      end

    end

    context 'keyword nested attributes' do 
      let(:o) { Otu.new(name: 'Some otu', tags_attributes: [ { keyword_attributes: {name: 'foo', definition: 'not bar'}} ]) }

      specify 'keyword can be created' do
        expect(o.save).to be_truthy
        expect(o.keywords.count).to eq(1)
        expect(Tag.count).to eq(1) 
        expect(Keyword.count).to eq(1) 
      end

      specify 'when tag is destroyed keyword is left' do
        expect(o.save).to be_truthy
        o.tags.destroy_all
        expect(o.tags.count).to eq(0)
        expect(o.keywords.count).to eq(0)
        expect(Keyword.first.name).to eq('foo')
      end

      specify 'keyword can be referenced' do
        o1 = Otu.new(name: 'Other otu', tags_attributes: [ {keyword: keyword} ])
        expect(o1.save).to be_truthy
        expect(o1.keywords).to contain_exactly(keyword)
      end
    end

    # TODO: Determine if we want to tag individual fields. 
    #  specify 'a attribute is actually a attribute of the tag object'
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end

