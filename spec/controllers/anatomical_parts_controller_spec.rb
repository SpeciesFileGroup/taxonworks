require 'rails_helper'

RSpec.describe AnatomicalPartsController, type: :controller do
  before(:each) do
    sign_in
  end

  let(:valid_session) { {} }

  describe 'GET templates' do
    render_views

    it 'returns unique names and uri templates in sorted order' do
      ancestor = FactoryBot.create(:valid_specimen)
      FactoryBot.create(:valid_taxon_determination, taxon_determination_object: ancestor)

      FactoryBot.create(:valid_anatomical_part, ancestor:, name: 'femur')
      FactoryBot.create(:valid_anatomical_part, ancestor:, name: 'Femur')
      FactoryBot.create(:valid_anatomical_part, ancestor:, name: nil, uri: 'http://purl.obolibrary.org/obo/UBERON_0000979', uri_label: 'leg')
      FactoryBot.create(:valid_anatomical_part, ancestor:, name: nil, uri: 'http://purl.obolibrary.org/obo/UBERON_0000979', uri_label: 'leg')

      get :templates, params: {}, session: valid_session, format: :json

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      names = data.select { |item| item['type'] == 'name' }.map { |item| item['name'] }
      uris = data.select { |item| item['type'] == 'uri' }

      expect(names).to match_array(['Femur', 'femur'])
      expect(uris).to eq([
        {
          'type' => 'uri',
          'uri' => 'http://purl.obolibrary.org/obo/UBERON_0000979',
          'uri_label' => 'leg'
        }
      ])
    end
  end
end
