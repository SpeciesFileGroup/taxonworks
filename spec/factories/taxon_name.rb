# This will guess the User class
FactoryGirl.define do
  factory :taxon_name do
    name "Aus"
    class_rank "NomenclaturalRank::ICZN::Governed::GenusGroup::Genus"
  end
end
