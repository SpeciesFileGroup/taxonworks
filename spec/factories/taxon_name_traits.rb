FactoryGirl.define do

  trait :mostly_empty_protonym do
    cached_name nil
    cached_author_year nil
    source_id nil
    year_of_publication nil
    verbatim_author nil
  end

  trait :parent_is_root do
    parent {
      p =  Protonym.where(parent_id: nil) 
      if p.blank?
        name = FactoryGirl.create(:root_taxon_name)
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
