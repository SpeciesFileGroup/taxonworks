require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  before(:all) do
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
    TaxonNameHierarchy.delete_all
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    Citation.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:root) { FactoryBot.create(:root_taxon_name, project_id: 1) }

  context 'with Roles attributes and purposefully invalid name (name is not capitalized for genus group rank' do
    # when models/role.rb has 
    # belongs_to :role_object, polymorphic: :true, validate: true
    # then this test fails, removing the validate: true lets it pass
    let(:p) {
      Protonym.new({
        parent: root,
        verbatim_name: 'complanulus',
        name: 'complanulus',
        year_of_publication: '1853',
        rank_class: Ranks.lookup('iczn'.to_sym, 'infragenus'),
        verbatim_author: 'Mannerheim',
        taxon_name_authors_attributes: [{
          last_name: 'Mannerheim',
          first_name: '',
          suffix: 'suffix'
        }]
      })
    }

    specify 'name does not save' do
      expect(p.save).to be_falsey
    end

    specify 'name saves after NotLatin' do
      p.taxon_name_classifications.build(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin')
      expect(p.save!).to be_truthy
    end
  end

end
