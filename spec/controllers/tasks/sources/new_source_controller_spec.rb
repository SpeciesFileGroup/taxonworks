require 'rails_helper'

describe Tasks::Sources::NewSourceController, type: :controller do
  render_views

  before(:each) do
    sign_in
  end

  let(:citation) { 'A new species of the spittlebug genus Ariptyelus Matsumura, 1940(Hemiptera: Cercopoidea: Aphrophoridae) from Luzon, Philippines' }

  describe 'GET crossref_preview' do
    specify 'renders the source payload when Crossref parsing succeeds' do
      source = Source::Bibtex.new(title: 'Resolved title')

      allow(Vendor::Serrano).to receive(:new_from_citation).with(citation: citation).and_return(source)

      get :crossref_preview, params: { citation: citation }, format: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['title']).to eq('Resolved title')
    end

    specify 'returns a user-facing error with DOI and BibTeX when Crossref returns unparsable BibTeX' do
      allow(Vendor::Serrano).to receive(:new_from_citation).with(citation: citation).and_raise(
        Vendor::Serrano::CrossrefBibtexParseError.new(
          doi: '10.3956/2026-102.1.37',
          bibtex: '@article{Thompson_2026, Jr._Yap_2026, ...}',
          message: 'Failed to parse BibTeX'
        )
      )

      get :crossref_preview, params: { citation: citation }, format: :json

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)

      expect(body['error']).to eq('Crossref returned BibTeX that could not be parsed.')
      expect(body['doi']).to eq('10.3956/2026-102.1.37')
      expect(body['bibtex']).to eq('@article{Thompson_2026, Jr._Yap_2026, ...}')
    end
  end
end
