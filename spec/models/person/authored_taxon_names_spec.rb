require 'rails_helper'

describe Person, type: :model do

  let(:p) { Person.create!(last_name: 'Smith', first_name: 'Jones') }
  let!(:root) {
    n = Protonym.stub_root
    n.save!
    n }
  let!(:s) { Protonym.create!(name: 'aus', parent: root, rank_class: Ranks.lookup(:iczn, :species), taxon_name_authors: [p] ) }

  specify 'on update authorship is updated' do
    p.update(last_name: 'Zorg')
    expect(s.reload.cached_author_year).to eq('Zorg')
  end

end
