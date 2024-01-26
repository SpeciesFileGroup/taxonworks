FactoryBot.define do
  factory :lead do
    parent_id { 1 }
    otu_id { 1 }
    text { "MyText" }
    origin_label { "MyString" }
    description { "MyText" }
    redirect_id { 1 }
    link_out { "MyText" }
    link_out_text { "MyString" }
    position { 1 }
    is_public { false }
    project_id { 1 }
    created_by_id { 1 }
    updated_by_id { 1 }
  end
end
