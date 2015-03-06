# Use protonym_factory for TaxonName factories.

FactoryGirl.define do
  factory :taxon_name, traits: [:housekeeping] do
    # THERE IS NO :valid_taxon_name, use :valid_protonym or :valid_combination instead
    #
#   factory :valid_taxon_name, traits: [:housekeeping, :parent_is_root]  do
#     name 'Adidae'
#     type 'Protonym' # !! must be present 
#     rank_class Ranks.lookup(:iczn, 'Family')
#   end
  end
end
