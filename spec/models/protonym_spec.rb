require 'spec_helper'

describe Protonym do

  let(:protonym) { Protonym.new }

  context "associations" do
    specify "original_description_source" do
      expect(protonym).to respond_to(:original_description_source)
    end
  end

end
