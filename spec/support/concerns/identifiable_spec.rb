shared_examples "identifiable" do

  let(:identifiable_class) {described_class.new()}
  # methods
  context "methods" do
    
    specify "has many identifiers" do
      expect(identifiable_class).to respond_to(:identifiers)
    end

    specify "identified?" do
      expect(identifiable_class.identified?).to eq(false)
    end

  end
end

