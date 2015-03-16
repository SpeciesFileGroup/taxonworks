require 'rails_helper'

describe Source::Human, :type => :model do
  let(:tom) { Person.create(last_name: 'Smith', first_name: 'Tom')  }
  let(:sue) { Person.create(last_name: 'Sunny', first_name: 'Sue')  }
  let(:franklin) { Person.create(last_name: 'Roosevelt', first_name: 'Franklin')  }

  let(:source_human) { Source::Human.new }

  context 'associations' do
    context 'has_many' do
      specify '#people' do
        expect(source_human.people << Person.new).to be_truthy
      end

      specify '#source_source_roles' do
        expect(source_human.source_source_roles << SourceSource.new).to be_truthy
      end

      specify '#roles' do
        expect(source_human.roles << Role.new).to be_truthy
      end
    end
  end

  context 'validation' do
    before { source_human.save }
    specify 'at least one person is provided' do
      expect(source_human.errors.include?(:base)).to be_truthy 
    end
  end

  context 'usage' do
    specify 'add a person, save the source' do
      expect(source_human.people << tom).to be_truthy   #must have source & person must be saved before << operator
      expect(source_human.people.first).to eq(tom.metamorphosize)
      expect(source_human.save).to be_truthy
    end

    specify 'add multiple people, save the source' do
      expect(source_human.people << tom).to be_truthy 
      expect(source_human.people << sue).to be_truthy 
      expect(source_human.save).to be_truthy
      expect(source_human.people.count).to eq(2)
    end
  end

  context '#cached'  do
    before {source_human.people << tom }
    specify '#cached is set before_save' do
      source_human.save!
      expect(source_human.cached.blank?).to be_falsey
    end

    specify '#cached is composed of last names' do
      source_human.save!
      expect(source_human.cached).to eq(tom.last_name)
    end

    specify '#cached with two people is joined with &' do
      source_human.people << sue
      source_human.save
      expect(source_human.cached).to eq(tom.last_name + ' & ' + sue.last_name)
    end 

    specify '#cached with three (or more) people comman with & between last two' do
      source_human.people << sue
      source_human.people << franklin 
      source_human.save
      expect(source_human.cached).to eq(tom.last_name + ', ' + sue.last_name + ' & ' + franklin.last_name)
    end 
  end

  context 'position' do
    before {  
      source_human.people << tom
      source_human.people << sue 
      source_human.people << franklin 
      source_human.save
    }
    specify 'is calculated' do
      expect(source_human.source_source_roles.first.position).to eq(1)
      expect(source_human.source_source_roles.second.position).to eq(2)
      expect(source_human.source_source_roles.third.position).to eq(3)
    end

    specify 'orders people' do
      source_human.reload
      expect(source_human.people.first.first_name).to eq('Tom')
      expect(source_human.people.second.first_name).to eq('Sue')
      expect(source_human.people.third.first_name).to eq('Franklin')
    end
  end

end
