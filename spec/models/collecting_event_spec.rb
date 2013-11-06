require 'spec_helper'

# A class representing a single biological property. Examples: "male", "adult", "host", "parasite".

describe CollectingEvent do

  let(:collecting_event) { CollectingEvent.new }

  context 'validation' do
    context 'requires' do
      before do
        collecting_event.save
      end

      specify 'at least some label is provided' do
        pending 
        # expect(collecting_event.errors.include?(:cached_display)).to be_true
      end
    end

    # format?!
    context 'property' do

    end

  end

  context 'concerns' do
    it_behaves_like 'citable'
  end

end

