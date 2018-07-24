FactoryBot.define do
  factory :label do
    text "MyString"
    total 1
    style "MyString"
    object_global_id "MyString"
    is_copy_edited false
    is_printed false
    project nil
  end
end
