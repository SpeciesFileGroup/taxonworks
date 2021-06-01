require 'rainbow'

module Support
  module Debug
    module TaxonNames

      # @return nil
      #  `puts` a report of ids of all currently passed taxon names, *ALL* (not just scoped) relationships, and the hierarchy like:
      #
      # 1 Root 
      # 2 Aidae 1
      # 3 Bidae 1
      # 4 Bus 2
      # 5 Ogus 3
      # 6 Bus aus 4
      # 7 Ogus bus 5
      # 8 Bus aus 2
      # 9 Ogus aus 3
      # ---
      # 4 8
      # 6 8
      # 5 9
      # 6 9
      # 5 10
      # 7 10
      # ---
      # 1 1
      # 2 2
      # 1 2
      # 3 3
      # 1 3
      # 4 4
      # 2 4
      # 1 4
      # 5 5
      # 3 5
      # 1 5
      # 6 6
      # 4 6
      # 2 6
      # 1 6
      # 7 7
      # 5 7
      # 3 7
      # 1 7
      # 8 8
      # 2 8
      # 1 8
      # 9 9
      # 3 9
      # 1 9
      # 10 10
      # 3 10
      # 1 10
      #
      def self.puts_names(names)
        names.each do |n|
          puts "#{n.id} #{n.cached} #{n.parent_id}"
        end

        puts '---'
        TaxonNameRelationship.all.each do |r|
          puts "#{r.subject_taxon_name_id} #{r.object_taxon_name_id}"
        end

        puts '---'
        TaxonNameHierarchy.all.each do |h|
          puts "#{h.ancestor_id} #{h.descendant_id}" 
        end

        return nil
      end
    end
  end
end
