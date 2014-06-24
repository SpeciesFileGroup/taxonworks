require 'spec_helper'

describe "api/v1/taxon_names/all.rabl" do

  let(:object) { FactoryGirl.create(:iczn_species) }

  let(:valid_json) {
    {
      :id => object.id,
      :parent_id => object.parent_id,
      # TODO: Discuss with the group about specification strategies 
      :rank => "species", # object.name
      :name => "vitis" # object.rank
    }.to_json
  }

  it 'renders an empty array when there are no taxon names' do
    assign(:names, [])
    render
    expect(rendered).to eq('[]')
  end

  it 'renders as many taxon names objects in an array as supplied' do
    assign(:names, [object, object.parent, object.parent.parent])
    render
    expect(JSON.parse(rendered).count).to eq(3)
  end

  it 'renders the array items as valid_json' do
    assign(:names, [object])
    render
    expect(rendered).to eq("[#{valid_json}]")
  end

end
