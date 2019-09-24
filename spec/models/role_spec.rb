require 'rails_helper'

describe Role, type: :model, group: [:sources, :people, :roles] do
  let(:role) { Role.new }
  let(:person) { FactoryBot.create(:valid_person, last_name: 'Smith') }
  let(:organization) { FactoryBot.create(:valid_organization) }

  context 'associations' do
    context 'belongs_to' do
      specify 'person' do
        expect(role).to respond_to(:person)
      end
    end
  end

  context 'validation' do
    specify '#type is required ' do
      role.valid?
      expect(role.errors.include?(:type)).to be_truthy
    end

    specify 'not role_object without agent' do
      expect(AttributionCopyrightHolder.create(role_object: FactoryBot.create(:valid_content)).persisted?).to be_falsey
    end

    specify 'not both of person and organization' do
      role.person = person
      role.organization = organization
      role.valid?
      expect(role.errors).to include(:person_id, :organization_id) 
    end

    specify '#organization is legal for organization roles' do
      r = AttributionCopyrightHolder.new(organization: organization)
      r.valid?
      expect(r.errors.include?(:organization_id)).to be_falsey
    end

    specify '#organization is illegal for non-organization roles' do
      r = SourceAuthor.new(organization: organization)
      r.valid?
      expect(r.errors.include?(:organization_id)).to be_truthy
    end

    specify 'An organization based role can be created' do
      expect(AttributionCopyrightHolder.create(organization: organization, role_object: FactoryBot.create(:valid_content)).persisted?).to be_truthy
    end

    specify 'A person can always be used' do
      expect(AttributionCopyrightHolder.create(person: person, role_object: FactoryBot.create(:valid_content)).persisted?).to be_truthy
    end

    # From Roles::Person concern
    context 'duplicate roles' do
      let!(:role_object) { FactoryBot.create(:valid_source_bibtex) }
      let!(:role1) { SourceAuthor.create(person: person, role_object: role_object) }

      specify 'are not permitted 1' do
        role2 = Role.new(person: person, role_object: role_object, type: 'SourceAuthor')
        expect(role2.valid?).to be_falsey
        expect(role2.errors.include?(:person_id)).to be_truthy
      end

      specify 'are not permitted 2' do
        role2 = Role.new(person_id: person.id, role_object: role_object, type: 'SourceAuthor')
        expect(role2.valid?).to be_falsey
        expect(role2.errors.include?(:person_id)).to be_truthy
      end

      specify 'are not permitted 3' do
        role2 = role_object.author_roles.build(person_id: person.id)
        expect(role2.valid?).to be_falsey
        expect(role2.errors.include?(:person_id)).to be_truthy
      end
    end
  end

  specify '#position is specified by acts_as_list' do
    a = FactoryBot.create(:valid_source_author)
    expect(a.position).to eq(1)
  end

  context 'auto-vetting people' do
    let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }
    let(:other_collecting_event) { FactoryBot.create(:valid_collecting_event) }

    before {
      collecting_event.collectors << person
    }

    specify 'a person with a single role is not vetted' do
      expect(person.roles.reload.size).to eq(1)
      expect(person.reload.type).to eq('Person::Unvetted')
    end

    specify 'a person with two roles becomes vetted' do
      other_collecting_event.collectors << person
      expect(person.roles.reload.size).to eq(2)
      expect(person.reload.type).to eq('Person::Vetted')
    end
  end

  # TODO: Very likely redundant with other cached specs
  context 'cascading #cached updates' do
    let!(:source) { Source::Bibtex.create!(bibtex_type: :article, title: 'Something', year: 2012)  }
    let!(:role) { Role.create!(role_object: source, person: person, type: 'SourceAuthor')  }

    specify 'before destroy' do
      expect(source.cached_author_string).to eq(person.last_name)
    end 

    specify 'after destroy 1' do
      role.destroy 
      expect(source.reload.cached_author_string).to eq(nil)
    end 
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
