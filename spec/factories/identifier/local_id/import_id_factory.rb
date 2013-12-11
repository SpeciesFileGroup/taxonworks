# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_local_id_import_id, :class => 'Identifier::LocalId::ImportId, traits: [:housekeeping]' do
  end
end
