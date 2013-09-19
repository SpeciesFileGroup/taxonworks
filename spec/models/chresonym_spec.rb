require 'spec_helper'

describe Chresonym do

  let(:chrysonym) { Chresonym.new }

  context "validation" do 
    context "requires" do
      before do
        chrysonym.valid?
      end

      specify "name" do
        expect(chrysonym.errors.include?(:name)).to be_false
      end

      specify "type" do
        expect(chrysonym.type).to eq('Chresonym')
      end
    end

  end


end
