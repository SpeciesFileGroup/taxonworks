require 'spec_helper'

describe TypeSpecimen do
  let(:type_specimen) { TypeSpecimen.new }

  context 'associations' do
    context 'belongs to' do
      
      specify 'taxon_name' do
        expect(type_specimen).to respond_to(:taxon_name)
      end

      specify 'biological_object' do
        expect(type_specimen).to respond_to(:biological_object)
      end
    end
  end

  context 'validations' do
    pending 'type_type should be defined in a constant for iczn'
    pending 'type_type should be defined in a constant for icn'
    pending 'taxon_name should always be type Protonym'
  end

  context 'methods/options' do
    pending 'a constant should relate type_type to valid biological_object subclass' do
      # for example {holotype: Specimen, syntype: Specimen, syntypes: Lot, paratypes: Lot, paratype: Specimen}
    end
    pending 'TypeDesignator role(s) should be possible when a specific person needs to be identified as the person who designated the type' 
    pending 'a source citation can identify where the type designation was made' 
  end

end
