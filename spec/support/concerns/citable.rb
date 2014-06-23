shared_examples 'citable' do
  
  # use, create (class_with_citations has to have an ID)
  let(:class_with_citations) {FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym)}
  # above modefies n = "ClassName::SubclassName" to "class_name_subclass_name"

  context 'associations' do
    specify 'has many citations - includes creating a citation' do
      expect(class_with_citations).to respond_to(:citations) # tests that the method citations exists
      expect(class_with_citations.citations.to_a).to eq([]) # there are no citations yet.

      expect(class_with_citations.citations << FactoryGirl.build(:citation, source: FactoryGirl.create(:valid_source_bibtex))).to be_truthy
      expect(class_with_citations.citations.count).to eq(1)
      expect(class_with_citations.save).to be_truthy
    end
  end

  context 'methods' do
    specify 'cited?' do
      expect(class_with_citations.cited?).to eq(false)
    end
  end
end

