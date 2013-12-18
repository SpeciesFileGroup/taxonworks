shared_examples "identifiable" do

  let(:identifiable_class) {FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym)}

  context "reflections / foreign keys" do
    specify "has many identifiers" do
      expect(identifiable_class).to respond_to(:identifiers)
    end
  end

  context "methods" do
    specify "identified?" do
      expect(identifiable_class.identified?).to eq(false)
    end
  end
end

