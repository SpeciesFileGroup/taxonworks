require 'rails_helper'

describe FactoryProjectHelpers, type: :model do
  describe '.assign_project_scoped' do
    specify 'associated object is created in the same project as the parent, not Current.project_id' do
      other_project = FactoryBot.create(:valid_project)
      citation = FactoryBot.create(:valid_citation, project: other_project)

      expect(citation.citation_object.project_id).to eq(other_project.id)
      expect(citation.citation_object.project_id).not_to eq(Current.project_id)
    end

    specify 'does not override an already-set association' do
      otu = FactoryBot.create(:valid_otu)
      citation = FactoryBot.create(:valid_citation, citation_object: otu)

      expect(citation.citation_object).to eq(otu)
    end

    specify 'does not override an already-set unsaved association' do
      otu = FactoryBot.build(:valid_otu)
      citation = FactoryBot.build(:valid_citation, citation_object: otu)

      expect(citation.citation_object).to equal(otu)
      expect(citation.citation_object).not_to be_persisted
    end
  end
end
