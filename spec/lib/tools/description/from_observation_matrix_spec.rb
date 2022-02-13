require 'rails_helper'
require 'tools/description/from_observation_matrix'

describe Tools::Description::FromObservationMatrix, type: :model, group: :observation_matrix do

  # See spec/support/shared_contexts/shared_observation_matrices.rb
  include_context 'complex observation matrix'

  # Alias library
  let(:description) { Tools::Description::FromObservationMatrix }

  specify 'otu_description 1' do
    d = description.new(
      observation_matrix_id: observation_matrix.id,
      project_id: observation_matrix.project_id,
      otu_id: otu4.id)
    expect(d.generated_description).to eq('Descriptor 1 State1. Descriptor 2 State6. Descriptor 5 3–4. Descriptor 6 4. Descriptor 7 absent.')
  end

  specify 'otu_description 2' do
    d = description.new(
      project_id: observation_matrix.project_id,
      otu_id: otu4.id)
    expect(d.generated_description).to eq('Descriptor 1 State1. Descriptor 2 State6. Descriptor 5 3–4. Descriptor 6 4. Descriptor 7 absent.')
  end

  # @ TODO: @proceps, you'll need to refactor to use the new observation_object paradigm
  xspecify 'otu_diagnosis 1' do
    d = description.new(
      observation_matrix_id: observation_matrix.id,
      project_id: observation_matrix.project_id,
      otu_id: otu5.id)
    expect(d.generated_diagnosis).to eq('Descriptor 6 1. Descriptor 2 State5.')
    expect(d.similar_objects.first[:otu_id]).to eq(otu1.id)
    expect(d.similar_objects.first[:similarities]).to eq(6)
  end

  # @ TODO: @proceps, you'll need to refactor to use the new observation_object paradigm
  xspecify 'otu_diagnosis 2' do
    row = r1.find_or_build_row(r1.observation_objects.first)
    d = description.new(observation_matrix_row_id: row.id)
    #expect(description.similar_objects.first[:otu_id]).to eq(otu5.id)
    expect(d.similar_objects.first[:similarities]).to eq(6)
  end

end
