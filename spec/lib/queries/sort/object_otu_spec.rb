require 'rails_helper'

describe Queries::Sort::ObjectOtu, type: :model do
  let(:otu_z) { Otu.create!(name: 'Zzz') }
  let(:otu_a) { Otu.create!(name: 'Aaa') }
  let(:otu_m) { Otu.create!(name: 'Mmm') }
  let(:subject_otu) { FactoryBot.create(:valid_otu) }
  let(:relationship) { FactoryBot.create(:valid_biological_relationship) }

  # Two determinations sharing a position (legacy data): the first by id is
  # the object's OTU, as for every other "first determination" sort.
  specify 'a tie on determination position is broken by id' do
    co = Specimen.create!
    td_first = TaxonDetermination.create!(taxon_determination_object: co, otu: otu_z)
    td_second = TaxonDetermination.create!(taxon_determination_object: co, otu: otu_a)
    td_second.update_column(:position, td_first.reload.position)
    # Rewrite the first determination so it no longer comes first in the table.
    td_first.update_column(:updated_at, Time.current)

    ba_co = BiologicalAssociation.create!(biological_association_subject: subject_otu, biological_association_object: co, biological_relationship: relationship)
    ba_otu = BiologicalAssociation.create!(biological_association_subject: subject_otu, biological_association_object: otu_m, biological_relationship: relationship)

    sorted = Queries::Pager.new(BiologicalAssociation.where(id: [ba_co.id, ba_otu.id]), sort: 'object_object_tag').ordered
    expect(sorted.map(&:id)).to eq([ba_otu.id, ba_co.id]) # Mmm < Zzz
  end

  specify 'the determination subquery orders by position, then id' do
    sql = Queries::Sort::Base.send(:object_otu_id_sql, id_expr: 'x.id', type_expr: "'CollectionObject'")
    expect(sql).to include('ORDER BY td.position, td.id')
  end
end
