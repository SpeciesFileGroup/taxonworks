require 'rails_helper'

describe 'Api::V1::Sources match', type: :request do
  include_context 'api context'

  let(:path) { '/api/v1/sources/match' }
  let(:citation) do
    'Ritzi, C.M. & J.O. Whitaker 2003. Fleas of Indiana. J. Parasitology ' \
      '10(2): 149-158.'
  end

  def article(
    author, year, title, volume,
    journal: 'J. Parasitology', pages: '149-158'
  )
    Source::Bibtex.create!(
      bibtex_type: 'article', author:, year:, title:, journal:, volume:,
      pages:, by: user
    )
  end

  let!(:source) do
    article('Ritzi, C.M. and Whitaker, J.O.', 2003, 'Fleas of Indiana', '10')
  end

  # Same authors and year, another title and volume: corroborated, but
  # disagrees.
  let!(:other_volume) do
    article('Ritzi, C.M. and Whitaker, J.O.', 2003, 'Mites of Ohio', '12')
  end

  # Only the authors agree: not corroborated.
  let!(:other_year) do
    article(
      'Ritzi, C.M. and Whitaker, J.O.', 2001, 'Ticks', '7',
      journal: 'Zootaxa', pages: '1-5'
    )
  end

  def json = JSON.parse(response.body)

  def candidate_ids = json['candidates'].map { |c| c['id'] }

  context 'without a project token' do
    before { get path, params: { citation: } }

    it_behaves_like 'a successful response'

    specify 'states the match' do
      expect(json['status']).to eq('matched')
      expect(json['match']['id']).to eq(source.id)
      expect(json['match']['cached']).to eq(source.reload.cached)
    end

    specify 'lists the corroborated candidates, the match first' do
      expect(candidate_ids).to eq([source.id, other_volume.id])
      expect(json['candidates'].map { |c| c['corroborated'] })
        .to eq([true, true])
    end

    specify 'states what agrees and disagrees' do
      c = json['candidates'].last
      expect(c['agrees'])
        .to contain_exactly('authors', 'year', 'journal', 'page')
      expect(c['disagrees']).to contain_exactly('title', 'volume')
    end

    specify 'does not list candidates where only the authors agree' do
      expect(candidate_ids).not_to include(other_year.id)
    end

    specify 'returns the citation as parsed' do
      expect(json['parsed']).to include(
        'surnames' => ['Ritzi', 'Whitaker'], 'year' => 2003, 'volume' => '10'
      )
    end
  end

  # As in catalogs: the page the name is on, no title.
  specify 'a citation without a title, placed by volume and page' do
    get path, params: {
      citation: 'Ritzi & Whitaker 2003. J. Parasitology 10: 152.'
    }
    expect(json['status']).to eq('matched')
    expect(json['match']['id']).to eq(source.id)
  end

  specify 'lists at most 5 candidates' do
    6.times { |i| article('Ritzi, C.M.', 2003, "Fleas #{i}", (20 + i).to_s) }
    get path, params: { citation: 'Ritzi 2003' }
    expect(json['candidates'].size).to eq(5)
  end

  specify 'an empty citation' do
    get path, params: { citation: ' ' }
    expect(json['status']).to eq('empty')
    expect(json['match']).to be_nil
    expect(json['candidates']).to eq([])
  end

  context 'with a project token' do
    let(:token_params) do
      { citation:, project_token: project.api_access_token }
    end

    before { ProjectSource.create!(project:, source: other_volume, by: user) }

    specify 'considers every Source, reporting in_project' do
      get path, params: token_params
      expect(json['match']['id']).to eq(source.id)
      expect(json['candidates'].map { |c| [c['id'], c['in_project']] })
        .to eq([[source.id, false], [other_volume.id, true]])
    end

    specify 'limit_to_project only considers the project\'s Sources' do
      get path, params: token_params.merge(limit_to_project: 'true')
      expect(candidate_ids).to eq([other_volume.id])
      expect(json['status']).to eq('unmatched')
    end

    context 'when the Source is duplicated' do
      let!(:duplicate) do
        article(
          'Ritzi, C.M. and Whitaker, J.O.', 2003, 'Fleas of Indiana', '10'
        )
      end

      specify 'matches the project\'s copy' do
        ProjectSource.create!(project:, source: duplicate, by: user)
        get path, params: token_params
        expect(json['status']).to eq('matched')
        expect(json['match']['id']).to eq(duplicate.id)
      end

      specify 'is ambiguous without a project to prefer' do
        get path, params: { citation: }
        expect(json['status']).to eq('ambiguous')
      end
    end
  end

  specify 'does not report in_project without a project token' do
    get path, params: { citation: }
    expect(json['candidates'].first).not_to have_key('in_project')
  end

  specify 'limit_to_project requires a project token' do
    get path, params: { citation:, limit_to_project: 'true' }
    expect(response).to have_http_status(:unprocessable_content)
  end

  context 'input longer than API_MATCH_MAX_LENGTH' do
    let(:too_long) { 'x' * (SourcesController::API_MATCH_MAX_LENGTH + 1) }

    specify 'a citation is refused' do
      get path, params: { citation: too_long }
      expect(response).to have_http_status(:unprocessable_content)
    end

    specify 'a field is refused' do
      get path, params: { citation:, title: too_long }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  specify 'an invalid project token is unauthorized' do
    get path, params: { citation:, project_token: 'nope' }
    expect(response).to be_unauthorized
  end
end
