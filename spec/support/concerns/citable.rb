shared_examples "citable" do

  let(:class_with_citations) {described_class.new()}

  context "reflections / foreign keys" do
    specify "has many citations" do
      expect(class_with_citations).to respond_to(:citations)
    end
  end

  context "methods" do
    specify "cited?" do
      expect(class_with_citations.cited?).to eq(false)
    end

  end
end

