# Unvetted person definition...
#
class Person::Unvetted < Person
  originates_from *[
    ImportDataset::DarwinCore::Checklist,
    ImportDataset::DarwinCore::Occurrences
  ].map(&:to_s)
end
