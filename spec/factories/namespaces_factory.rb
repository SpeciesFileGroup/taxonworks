FactoryGirl.define do
  factory :namespace do
  end

  factory :valid_namespace, class: Namespace do
    name 'All my things'
    short_name 'AMT'
  end
end
