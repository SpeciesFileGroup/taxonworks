shared_examples "identifiable" do

  let(:identifiable_class) {described_class.new()}

  context "reflections / foreign keys" do
    specify "has many identifiers" do
      expect(identifiable_class).to respond_to(:identifier)
    end
  end

  context "methods" do
    specify "identified?" do
      expect(identifiable_class.identified?).to eq(false)
    end

  end
end

