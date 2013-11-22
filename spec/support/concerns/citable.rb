shared_examples 'citable' do
  
  # use, create (class_with_citations has to have an ID)
  let(:class_with_citations) {FactoryGirl.create("valid_#{described_class.name.underscore}".to_sym)}

  context 'associations' do
    specify 'has many citations - includes creating a citation' do
      expect(class_with_citations).to respond_to(:citations) # tests that the method citations exists
      expect(class_with_citations.citations.to_a).to eq([]) # there are no citations yet.

      expect(class_with_citations.citations << Citation.new(source: FactoryGirl.create(:valid_bibtex_source)) ).to be_true
      expect(class_with_citations.citations).to have(1).things
      expect(class_with_citations.save).to be_true
    end
  end

  context 'methods' do
    specify 'cited?' do
      expect(class_with_citations.cited?).to eq(false)
    end
  end
end

