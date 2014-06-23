shared_examples 'taggable' do

  let(:class_with_tags) {FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym)}

  context 'associations' do
    specify 'has many tags' do
      expect(class_with_tags).to respond_to(:tags) 
      expect(class_with_tags.tags.to_a).to eq([]) # there are no tags yet.

      expect(class_with_tags.tags << FactoryGirl.build(:valid_tag)).to be_truthy
      expect(class_with_tags.tags).to have(1).things
      expect(class_with_tags.save).to be_truthy
    end
  end

  context 'scopes' do
    context '.with_tags' do
      before {
        @a = FactoryGirl.create(:valid_keyword)
        @b = Tag.create(tag_object: class_with_tags, keyword: @a)
      }

      specify 'without tags' do
        expect(class_with_tags.class.without_tags.count).to eq(0)
      end 

      specify 'with_tags' do
        expect(class_with_tags.class.with_tags.pluck(:id)).to eq( [ class_with_tags.id  ] )
      end
    end

    context '.without_tags' do
       specify 'without tags' do
        # Fudging this for STI reasons
        expect(class_with_tags.class.without_tags.pluck(:id)).to eq([class_with_tags.id])
      end 

      specify 'with_tags' do
        expect(class_with_tags.class.with_tags.to_a).to eq( [ ] )
      end

    end
  end

  context 'methods' do
    specify 'tagged?' do
      expect(class_with_tags.tagged?).to eq(false)
    end
  end
end

