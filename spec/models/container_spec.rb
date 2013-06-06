require 'spec_helper'

describe Container do

  let(:c) { Container.new }

  # Foreign key relationships
  context 'reflections / foreign keys' do 
    specify "it has many specimens" do
      expect(c).to respond_to(:specimens)
    end

    specify "container_type" do
      expect(c).to respond_to(:specimens)
    end
  end

  context "concerns" do
    it_behaves_like "identifiable"
    it_behaves_like "containable"
  end

end
