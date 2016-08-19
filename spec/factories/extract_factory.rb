FactoryGirl.define do
  factory :extract, traits: [:housekeeping] do
    factory :valid_extract do
      quantity_value "9.99"
      quantity_unit "MyString"
      quantity_concentration "9.99"
      verbatim_anatomical_origin "MyString"
      year_made 1
      month_made 1
      day_made 1
    end
  end
end
