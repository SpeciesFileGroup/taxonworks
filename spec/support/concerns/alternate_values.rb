shared_examples 'alternate_values' do

  let(:class_with_alt) { FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym) }

  context 'reflections / foreign keys' do
    specify 'has many alternates' do
      expect(class_with_alt).to respond_to(:alternate_values)
      expect(class_with_alt.alternate_values.count == 0).to be_true
    end
    specify 'can add an alternate value' do
      pending
    end
    specify 'can not add alternate values to NON_ANNOTATABLE_COLUMNS' do
      pending
    end
    specify 'can not add note to a non-existent attribute (column)' do
      pending
    end
  end

  context 'methods' do
    specify 'has_alternate_values?' do
      pending
    end
    specify 'original_value' do
      pending
    end
  end
end