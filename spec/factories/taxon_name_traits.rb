FactoryGirl.define do

  trait :mostly_empty_protonym do
    cached_html nil
    cached_author_year nil
    source_id nil
    year_of_publication nil
    verbatim_author nil
  end

  trait :parent_is_root do
    parent {
      p =  Protonym.where(parent_id: nil) 
      if p.blank?
        # !! Note the strategy, build, not create, and provide a dummy ID so that validation passes when TaxonName#parent.id is checked.
        name = FactoryGirl.build(:root_taxon_name, id: Faker::Number.number(5))  
      else
        name = p.first
      end
      name 
    }
    # ignore do
    #   associated_attributes nil
    # end
    #
    # after_create do |object, evaluator|
    #   # Use the ignored associated_attributes when creating the associated object
    #   associated_object = AssociatedModel.new(evaluator.associated_attributes)
    #   end
  end
end
