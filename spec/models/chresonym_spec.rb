require 'spec_helper'

describe Chrysonym do

  let(:chrysonym) { Chrysonym.new }

  context "validation" do 
    context "requires" do
      before do
        chrysonym.valid?
      end

      specify "name" do
        expect(chrysonym.errors.include?(:name)).to be_false
      end

      specify "type" do
        expect(chrysonym.type).to eq('Chrysonym')
      end
    end

  end


end
