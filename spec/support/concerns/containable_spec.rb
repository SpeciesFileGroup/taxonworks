shared_examples "containable" do

  let(:containable_class) {described_class.new()}

  context "methods" do

    specify "contained?" do
      expect(containable_class.contained?).to eq(false)
    end

    # see https://github.com/collectiveidea/awesome_nested_set/blob/master/lib/awesome_nested_set/awesome_nested_set.rb"
    context "from awesome_nested_set" do
      specify "root" do
        expect(containable_class).to respond_to(:root)
      end
    end

  end
end

