# !! Use protonym factories for taxon names!
FactoryBot.define do
  factory :taxon_name, traits: [:housekeeping] do
  
    initialize_with { new(type: type) } 

    # This is a stub deal with automated Project related checks and warnings.
    factory :valid_taxon_name, traits: [:housekeeping, :parent_is_root]  do
      name { 'Adidae' }
      type { 'Protonym' } 
      rank_class { Ranks.lookup(:iczn, 'Family') }

      # TODO: after_save callbacks not hit, seems this is bad though
      before(:create) do |name|  
        name.cached_html = 'Adidae'
        name.cached = 'Adidae'
      end 
    end
  end
end
