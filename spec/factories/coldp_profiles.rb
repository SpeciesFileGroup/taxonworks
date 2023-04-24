FactoryBot.define do
  factory :coldp_profile do
    title_alias { "MyString" }
    project { nil }
    otu { nil }
    prefer_unlabelled_otu { false }
    checklistbank { 1 }
    export_interval { "MyString" }
  end
end
