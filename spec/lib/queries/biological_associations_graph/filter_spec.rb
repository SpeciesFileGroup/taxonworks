require 'rails_helper'

describe Queries::BiologicalAssociationsGraph::Filter, type: :model, group: [:filter, :biological_association] do

  let(:o1) { Otu.create!(name: 'small') }
  let(:o2) { Otu.create!(name: 'big') }
  let(:o3) { Specimen.create! }

  let!(:r1) { FactoryBot.create(:valid_biological_relationship) }
  let!(:r2) { FactoryBot.create(:valid_biological_relationship) }

  let!(:ba1) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o2, biological_relationship: r1) }
  let!(:ba2) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: r1) }
  let!(:ba3) { BiologicalAssociation.create!(biological_association_subject: o2, biological_association_object: o3, biological_relationship: r2) }

  let(:root) { FactoryBot.create(:root_taxon_name) }

  let(:query) { Queries::BiologicalAssociationsGraph::Filter }


  # STUB

end
