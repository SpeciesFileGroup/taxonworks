require 'spec_helper'

describe Tag do

  let(:tag) {FactoryGirl.build(:tag)}

  context 'associations' do
    specify 'tag_object' do 
      expect(tag.tag_object = FactoryGirl.create(:valid_biocuration_class)).to be_true
    end

    specify 'keyword' do
      expect(tag.keyword = FactoryGirl.create(:valid_keyword)).to be_true
    end
  end

  context 'validation' do
    before(:each) do
      tag.valid?
    end

    specify 'a tag object is required' do 
      expect(tag.errors.include?(:tag_object)).to be_true
    end

    specify 'a keyword is required' do
      expect(tag.errors.include?(:keyword)).to be_true
    end

    specify 'a topic can not be used' do
      t = Topic.new(name: 'foo', definition: 'Something about foo')
      expect{tag.keyword = t}.to raise_error
    end

    specify 'a tagged object is only tagged once per keyword' do
      b = FactoryGirl.build(:valid_source_bibtex)
      k = FactoryGirl.build(:valid_keyword)
      tag.tag_object = b
      tag.keyword = k
      tag.valid?
      expect(tag.errors.include?(:keyword)).to be_false
      expect(tag.errors.include?(:tag_object)).to be_false
      tag.save!
      dupe_tag = FactoryGirl.build(:tag, keyword: k, tag_object: b) 
      dupe_tag.valid?
      expect(dupe_tag.errors.include?(:keyword_id)).to be_true
    end

   specify 'keywords scope can be limited with Keyword#can_tag' do
     a = FactoryGirl.create(:valid_biocuration_group)
     b = FactoryGirl.create(:valid_specimen)
     t = Tag.new(tag_object: b, keyword: a)
     expect(t.valid?).to be_false
     expect(t.errors.include?(:keyword)).to be_true 
   end

    specify 'tag_object class can be limited with TagObject#taggable_with' do
      a = FactoryGirl.create(:valid_keyword)
      b = FactoryGirl.create(:valid_biocuration_class)
      t = Tag.new(tag_object: b, keyword: a)
      expect(t.valid?).to be_false
      expect(t.errors.include?(:tag_object)).to be_true 
    end

    context 'STI based tag behaviour' do
      before(:each) {
        tag.keyword = FactoryGirl.create(:valid_keyword) 
        tag.tag_object = FactoryGirl.create(:valid_specimen)
      }

      specify 'tagging an subclass of an STI model instance *stores* the tag_type as the superclass' do
        expect(tag.save).to be_true
        expect(tag.tag_object_type).to eq('CollectionObject')
      end

      specify 'tagging an subclass of an STI model instance, with subclass namespace, *stores* the tag_type as the superclass' do
        tag.tag_object = FactoryGirl.create(:valid_container_box)
        expect(tag.save).to be_true
        expect(tag.tag_object_type).to eq('Container')
      end

      specify 'tagging a subclass of an STI model *returns* the subclassed object' do
        expect(tag.save).to be_true
        expect(tag.tag_object.class).to eq(Specimen) 
      end
    end

    context 'acts_as_list' do
      specify 'position is set' do
        t1 = FactoryGirl.create(:valid_tag)
        expect(t1.position).to eq(1)
      end
    end

    # TODO: Determine if we want to tag individual fields. 
    #  specify 'a attribute is actually a attribute of the tag object'
  end

end

