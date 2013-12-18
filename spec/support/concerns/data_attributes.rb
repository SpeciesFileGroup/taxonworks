shared_examples 'data_attributes' do
  
  # use, create (class_with_data_attributess has to have an ID)
  let(:class_with_data_attributes) {FactoryGirl.create("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym)}
  # above modifies n = "ClassName::SubclassName" to "class_name_subclass_name"

  context 'associations' do
    specify 'has many data_attributes - includes creating a data_attribute' do
      expect(class_with_data_attributess).to respond_to(:data_attributes) 
      expect(class_with_data_attributess.data_attributes.to_a).to eq([]) 

      expect(class_with_data_attributess.data_attributes << FactoryGirl.build(:data_attribute, value: 10, import_predicate: 'foos')).to be_true
      expect(class_with_data_attributess.data_attributes).to have(1).things
      expect(class_with_data_attributess.save).to be_true
    end
  end

  context 'methods' do
    specify 'has_data_attributes?' do
      expect(class_with_data_attributess.has_data_attributes?).to eq(false)
    end
  end
end

