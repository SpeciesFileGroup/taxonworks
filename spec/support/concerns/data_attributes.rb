shared_examples 'data_attributes' do
  
  # use, create (class_with_data_attributess has to have an ID)
  let(:class_with_data_attributes) {FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym)}
  # above modifies n = "ClassName::SubclassName" to "class_name_subclass_name"

  context 'associations' do
    specify 'has many data_attributes - includes creating a data_attribute' do
      expect(class_with_data_attributes).to respond_to(:data_attributes) 
      expect(class_with_data_attributes.data_attributes.to_a).to eq([]) 
      expect(class_with_data_attributes.data_attributes << FactoryGirl.build(:data_attribute, value: '10', import_predicate: 'foos', type: 'DataAttribute::ImportAttribute')).to be_true
      expect(class_with_data_attributes.data_attributes).to have(1).things
      expect(class_with_data_attributes.save).to be_true
    end
  end

  context 'methods' do
    specify 'has_data_attributes?' do
      expect(class_with_data_attributes.has_data_attributes?).to eq(false)
    end

    specify 'keyword_value_hash' do
      class_with_data_attributes.data_attributes.delete_all # sanity !! CAREFUL DON'T DO THIS TO PROJECT!
      class_with_data_attributes.data_attributes << FactoryGirl.build(:data_attribute_import_attribute, value: '10', import_predicate: 'legs')
      expect(class_with_data_attributes.data_attributes).to have(1).things
      expect(class_with_data_attributes.keyword_value_hash).to eq('legs' => '10')
      class_with_data_attributes.data_attributes << FactoryGirl.build(:valid_data_attribute_internal_attribute)
      expect(class_with_data_attributes.keyword_value_hash).to eq('legs' => '10', 'Color' => 'purple')
    end
  end

  context 'adding lots of attributes' do
    specify 'add_import_attributes(hash) should add multiple pairs of ImportAttributes' do
      skip 
    end 
  end
end

