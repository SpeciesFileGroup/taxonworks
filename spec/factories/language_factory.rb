# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :language, traits: [:creator_and_updater] do
    factory :valid_language do
      alpha_3_bibliographic 'ABC'
      english_name 'English'
    end

    factory :english do
      alpha_3_bibliographic 'eng'
      alpha_2 'en'
      english_name 'English'
      french_name 'anglais'
    end

    factory :russian do
      alpha_3_bibliographic 'rus'
      alpha_2 'ru'
      english_name 'Russian'
      french_name 'russe'
    end

    factory :creole_eng do
      alpha_3_bibliographic 'cpe'
      # alpha_2 nil - no 2 letter abbreviation
      english_name '"Creoles and pidgins, English based"'
      french_name 'russe'
    end

  end

end
