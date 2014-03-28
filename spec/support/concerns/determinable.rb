shared_examples "determinable" do
  let(:determinable_class) { FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym) }

  context "reflections / foreign keys" do
    specify "it has many Otus through determinations" do
      expect(determinable_class).to respond_to(:otus)
    end

    specify "TaxonDeterminations" do
      expect(determinable_class).to respond_to(:taxon_determinations)
    end

  end
end

