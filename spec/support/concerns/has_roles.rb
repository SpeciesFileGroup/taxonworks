shared_examples "has_roles" do

  let(:class_with_roles) {described_class.new()}

  context "reflections / foreign keys" do
    specify "has many roles" do
      expect(class_with_roles).to respond_to(:roles)
    end
  end

  context "methods" do
    specify "has_roles?" do
      expect(class_with_roles.has_roles?).to eq(false)
    end

  end
end

