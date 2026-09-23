require 'rails_helper'

describe Queries::AlternateValue::Filter, type: :model, group: :alternate_values do
  
  let(:query) { Queries::AlternateValue::Filter.new({}) }

  let(:p) { ActionController::Parameters.new }

  specify '#ignores_project? with alternatve_value_object' do
    q = Queries::AlternateValue::Filter.new( p.merge(alternate_value_object_id: 1, alternate_value_object_type: 'GeographicArea'))
    expect(q.ignores_project?).to be_truthy
  end

  specify '#ignores_project? with shallow_params 1' do
    q = Queries::AlternateValue::Filter.new( p.merge(geographic_area_id: '123'))
    expect(q.ignores_project?).to be_truthy
  end

  specify '#ignores_project? with shallow_params 2' do
    q = Queries::AlternateValue::Filter.new( p.merge(otu_id: '123') )
    expect(q.ignores_project?).to be_falsey
  end

  context 'community annotations' do
    let!(:project_annotation) do
      AlternateValue::AlternateSpelling.create!(
        alternate_value_object: FactoryBot.create(:valid_keyword),
        alternate_value_object_attribute: 'name',
        value: 'Blorf'
      )
    end

    let!(:community_annotation) do
      AlternateValue::AlternateSpelling.create!(
        alternate_value_object: FactoryBot.create(:valid_serial),
        alternate_value_object_attribute: 'name',
        value: 'Blorf'
      )
    end

    specify 'are excluded without `api`' do
      q = Queries::AlternateValue::Filter.new(p.merge(project_id: 1))
      expect(q.all.to_a).to contain_exactly(project_annotation)
    end

    specify 'are included with `api`' do
      q = Queries::AlternateValue::Filter.new(p.merge(project_id: 1, api: true))
      expect(q.all.to_a).to contain_exactly(project_annotation, community_annotation)
    end

    specify 'are reachable by `alternate_value_object_type` without `api`' do
      q = Queries::AlternateValue::Filter.new(p.merge(project_id: 1, alternate_value_object_type: 'Serial'))
      expect(q.all.to_a).to contain_exactly(community_annotation)
    end
  end
end
