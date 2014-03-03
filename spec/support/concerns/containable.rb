shared_examples "containable" do

  let(:containable_class) {described_class.new()}
 
  context "reflections / foreign keys" do
    specify "has one" do
      expect(containable_class).to respond_to(:container)
    end
  end 

  context "methods" do
    specify "contained?" do
      expect(containable_class.contained?).to eq(false)
    end
  end
end

