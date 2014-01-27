shared_examples 'taggable' do

  let(:class_with_tags) {FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym)}

  context 'associations' do
    specify 'has many tags' do
      expect(class_with_tags).to respond_to(:tags) 
      expect(class_with_tags.tags.to_a).to eq([]) # there are no tags yet.

      expect(class_with_tags.tags << FactoryGirl.build(:valid_tag)).to be_true
      expect(class_with_tags.tags).to have(1).things
      expect(class_with_tags.save).to be_true
    end
  end

  context 'methods' do
    specify 'tagged?' do
      expect(class_with_tags.tagged?).to eq(false)
    end
  end
end

