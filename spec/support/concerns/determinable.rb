shared_examples "determinable" do
  let(:determinable_class) {described_class.new()}

  context "reflections / foreign keys" do
    specify "it has many Otus through determinations" do
      expect(determinable_class).to respond_to(:otus)
    end

    specify "TaxonDeterminations" do
      expect(determinable_class).to respond_to(:taxon_determinations)
    end

  end
end

