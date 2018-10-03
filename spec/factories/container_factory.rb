FactoryBot.define do
  factory :container, traits: [:housekeeping] do
    factory :valid_container, aliases: [:valid_container_site] do
      type { 'Container::Site' }
    end
  end
end
