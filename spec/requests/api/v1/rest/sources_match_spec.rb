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
        .to contain_exactly('authors', 'year', 'journal', 'first_page')
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
    before do
      ProjectSource.create!(project:, source: other_volume, by: user)
      get path, params: { citation:, project_token: project.api_access_token }
    end

    specify 'only considers the project\'s Sources' do
      expect(candidate_ids).to eq([other_volume.id])
      expect(json['status']).to eq('unmatched')
    end

    specify 'does not report in_project (all are)' do
      expect(json['candidates'].first).not_to have_key('in_project')
    end
  end

  specify 'an invalid project token is unauthorized' do
    get path, params: { citation:, project_token: 'nope' }
    expect(response).to be_unauthorized
  end
end
