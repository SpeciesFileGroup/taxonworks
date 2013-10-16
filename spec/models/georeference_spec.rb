require 'spec_helper'

describe Georeference do

  let(:georeference) { Georeference.new }
  context 'associations' do
    context 'belongs_to' do

      specify 'geographic_item' do
        expect(georeference).to respond_to :geographic_item
      end

      specify 'error_geographic_item' do
        expect(georeference).to respond_to :error_geographic_item
      end

      specify 'collecting_event' do
        expect(georeference).to respond_to :collecting_event
      end
    end

  end

end
