require 'spec_helper'

describe Namespace do
  let(:namespace) { Namespace.new }

  context "validation" do
    context "required / not nil properties" do
      before do
        namespace.save
      end
      specify "name" do
        expect(namespace.errors.include?(:name)).to be_true
      end 

      specify "short_name" do
        expect(namespace.errors.include?(:short_name)).to be_true
      end 
    end
  end

end
