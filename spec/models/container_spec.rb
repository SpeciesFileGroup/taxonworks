require 'spec_helper'

describe Container do

  let(:container) { Container.new }

  # Foreign key relationships
  context 'reflections / foreign keys' do 
    specify "it has many specimens" do
      expect(container).to respond_to(:specimens)
    end

    specify "container_type" do
      expect(container).to respond_to(:specimens)
    end
  end

  # see https://github.com/collectiveidea/awesome_nested_set/blob/master/lib/awesome_nested_set/awesome_nested_set.rb"
  context "from awesome_nested_set" do
    specify "root" do
      expect(container).to respond_to(:root)
    end
  end

  context "concerns" do
    it_behaves_like "identifiable"
    it_behaves_like "containable"
  end

end
