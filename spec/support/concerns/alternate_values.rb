shared_examples 'alternate_values' do

  let(:class_with_alt) { FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym) }

  context 'reflections / foreign keys' do
    specify 'has many alternates' do
      expect(class_with_alt).to respond_to(:alternate_values)
      expect(class_with_alt.alternate_values.count == 0).to be_true
    end

    # See alternate_values_spec for test on field restrictions
  end

  context 'methods' do
    specify 'has_alternate_values?' do
      expect(class_with_alt).to respond_to(:has_alternate_values?)
      expect(class_with_alt.has_alternate_values?).to be_false
    end
    
  end

end
