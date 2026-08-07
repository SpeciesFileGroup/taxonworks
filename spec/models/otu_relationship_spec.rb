require 'rails_helper'

describe OtuRelationship, type: :model, group: :otu do

  let(:otu_relationship) { OtuRelationship.new }

  specify 'subject_otu is requred' do
    otu_relationship.valid?
    expect(otu_relationship.errors.messages.include?(:subject_otu)).to be_truthy
  end

end


