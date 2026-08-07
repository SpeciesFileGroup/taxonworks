# Shared code for providing alternate values for individual columns.
#
module TaxonName::OtuSyncronization
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    # @return [Int, false]
    # @params user_id [User#id] required
    # @params user_id [TaxonName#id] required
    #    the number of names created
    def synchronize_otus(taxon_name_id: nil, user_id: nil, mode: :all_valid)
      return false if mode.nil? || taxon_name_id.nil? || user_id.nil?
      t = TaxonName.find(taxon_name_id)
      i = 0
      names = case mode
              when :all_valid
                t.self_and_descendants.that_is_valid.without_otus
              when :child_valid
                t.children.that_is_valid.without_otus
              when :all_without
                t.self_and_descendants.without_otus
              when :all_invalid
                t.self_and_descendants.that_is_invalid.without_otus
              when :child_invalid
                t.children.that_is_invalid.without_otus
              else
                []
              end
      begin
        names.each do |n|
          Otu.create!(by: user_id, taxon_name: n, project_id: t.project_id)
          i += 1
        end
      rescue ActiveRecord::RecordInvalid
        return false
      end
      i
    end

  end
end
