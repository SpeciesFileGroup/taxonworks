require 'rails_helper'

describe CombinationsController, type: :controller do
  let(:valid_session) { {} }

  before do
    sign_in
  end

  describe 'DELETE #destroy (JSON)' do
    context 'when the combination is used as an OTU taxon name' do
      let!(:combination) { FactoryBot.create(:valid_combination) }
      let!(:otu) { Otu.create!(name: 'otu_using_combination', taxon_name: combination) }

      specify 'does not destroy the combination and returns unprocessable_entity with errors' do
        expect do
          delete :destroy, params: { id: combination.to_param, format: :json }, session: valid_session
        end.not_to change(Combination, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(response.body.downcase).to include('dependent otus')
      end
    end

    context 'when the combination has no associations blocking destroy' do
      let!(:combination) { FactoryBot.create(:valid_combination) }

      specify 'destroys the combination and returns no_content' do
        expect do
          delete :destroy, params: { id: combination.to_param, format: :json }, session: valid_session
        end.to change(Combination, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_blank
      end
    end
  end
end
