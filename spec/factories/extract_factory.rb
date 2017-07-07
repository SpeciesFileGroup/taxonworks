FactoryGirl.define do
  factory :extract, traits: [:housekeeping] do
    factory :valid_extract do
      quantity_value "9.99"
      quantity_unit "meters"
      concentration_value "9.99"
      concentration_unit "meters"
      verbatim_anatomical_origin "MyString"
      year_made Time.now.year
      month_made 1
      day_made 1
    end
  end
end
