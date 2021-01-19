module Protonym::SoftValidationExtensions

  module Klass

    VALIDATIONS = {
      sv_validate_parent_rank: {
        set:         :validate_parent_rank,
        resolution:  [],
        name:        'Validate parent rank',
        description: 'Validates parent rank.'
      },

      sv_potential_family_homonyms: { set: :potential_homonyms, has_fix: false},
      sv_potential_genus_homonyms: { set: :potential_homonyms, has_fix: false},
      sv_potential_species_homonyms: { set: :potential_homonyms, has_fix: false},
      sv_missing_original_genus: { set: :missing_relationships, has_fix: false},
      sv_missing_type_species: { set: :missing_relationships, has_fix: false},
      sv_missing_type_genus: { set: :missing_relationships, has_fix: false},
      sv_missing_substitute_name: { set: :missing_relationships, has_fix: false},
      sv_missing_part_of_speach: { set: :missing_classifications, has_fix: false},
      sv_missing_gender: { set: :missing_classifications, has_fix: false},
      sv_species_gender_agreement: { set: :species_gender_agreement, has_fix: false},
      sv_species_gender_agreement_not_required: { set: :species_gender_agreement, has_fix: false},
      sv_type_placement: { set: :type_placement, has_fix: false},
      sv_type_placement1: { set: :type_placement, has_fix: false},
      sv_primary_types: { set: :primary_types, has_fix: false},
      sv_primary_types_repository: { set: :primary_types, has_fix: false},
#      sv_validate_coordinated_names: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_source: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_author: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_year: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_gender: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_part_of_speach: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_original_genus: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_original_subgenus: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_original_species: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_original_subspecies: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_original_variety: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_original_form: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_type_species: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_type_species_type: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_type_genus: { set: :validate_coordinated_names, has_fix: true},
      sv_validate_coordinated_names_type_specimen: { set: :validate_coordinated_names, has_fix: true},
      sv_single_sub_taxon: { set: :single_sub_taxon, has_fix: true},
      sv_parent_priority: { set: :parent_priority, has_fix: false},
      sv_homotypic_synonyms: { set: :homotypic_synonyms, has_fix: false},
      sv_family_is_invalid: { set: :family_is_invalid, has_fix: false},
      sv_family_is_invalid_no_substitute: { set: :family_is_invalid, has_fix: false},
      sv_source_not_older_then_description: { set: :dates, has_fix: false},
      sv_original_combination_relationships: { set: :original_combination_relationships, has_fix: false},
      sv_extant_children: { set: :extant_children, has_fix: false},
      sv_protonym_to_combination: { set: :protonym_to_combination, has_fix: false},
      sv_missing_roles: { set: :missing_roles, has_fix: false},
      sv_year_is_not_required: { set: :year_is_not_required, has_fix: true },
      sv_author_is_not_required: { set: :author_is_not_required, has_fix: true },
      sv_misspelling_roles_are_not_required: { set: :roles_are_not_required, has_fix: true },
      sv_misspelling_author_is_not_required: { set: :roles_are_not_required, has_fix: true },
      sv_misspelling_year_is_not_required: { set: :roles_are_not_required, has_fix: true }
    }.freeze

    VALIDATIONS.each_key do |k|
      Protonym.soft_validate(k, VALIDATIONS[k])
    end
  end

  module Instance
    def sv_source_not_older_then_description
      if self.source && self.year_of_publication
        soft_validations.add(:base, 'The year of publication of the taxon and the year in the original reference do not match') if self.try(:source).try(:year) != self.year_of_publication
      end
    end

    def sv_validate_parent_rank
      if self.rank_class && self.id == self.cached_valid_taxon_name_id
        if rank_string == 'NomvnclaturalRank' || self.parent.rank_string == 'NomenclaturalRank' || !!self.iczn_uncertain_placement_relationship
          true
        elsif !self.rank_class.valid_parents.include?(self.parent.rank_string)
          soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name}). The name should be marked as 'Incertae sedis'", resolution: 'path_to_edit_protomy')
        end
      end
    end

    def sv_missing_type_species
      if is_genus_rank? && self.type_species.nil? && is_available?
        soft_validations.add(:base, 'Missing relationship: Type species is not selected')
      end
    end

    def sv_missing_type_genus
      if is_family_rank? && self.type_genus.nil? && is_available?
        soft_validations.add(:base, 'Missing relationship: Type genus is not selected')
      end
    end

    def sv_missing_substitute_name
      if !self.iczn_set_as_homonym_of.nil? || !TaxonNameClassification.where_taxon_name(self).with_type_string('TaxonNameClassification::Iczn::Available::Invalid::Homonym').empty?
        if self.iczn_set_as_synonym_of.nil? && is_available?
          soft_validations.add(:base, 'Missing relationship: The name is a homonym, but a substitute name is not selected')
        end
      end
    end

    def sv_missing_part_of_speach
      if is_species_rank? && self.part_of_speech_class.nil? && !has_misspelling_relationship? && is_available?

        z = TaxonNameClassification.
            joins(:taxon_name).
            where(taxon_names: { name: name, project_id: project_id }).
            where("taxon_name_classifications.type LIKE 'TaxonNameClassification::Latinized::PartOfSpeech%'").
            group(:type).
            count(:type)

        if z.empty?
          soft_validations.add(:base, 'Part of speech is not specified. Please select if the name is a noun or an adjective.')
        else
          l = []
          z.each do |key, value|
            l << (value == 1 ? " as '#{key.constantize.label}' #{value.to_s} time" : " as '#{key.constantize.label}' #{value.to_s} times")
          end
          soft_validations.add(:base, 'Part of speech is not specified. The name was previously used' + l.join('; '))
        end
      end
    end

    def sv_missing_gender
      if is_genus_rank? && self.gender_class.nil? && !self.cached_misspelling && is_available?
        g = genus_suggested_gender
        soft_validations.add(:base, "Gender is not specified#{ g.nil? ? '' : ' (possible gender is ' + g + ')'}")
      end
    end

    def sv_species_gender_agreement
      if is_species_rank?
        s = part_of_speech_name
        if !s.nil? && is_available?
          if %w{adjective participle}.include?(s)
            if !feminine_name.blank? && !masculine_name.blank? && !neuter_name.blank? && name != masculine_name && name != feminine_name && name != neuter_name
              soft_validations.add(:base, 'Species name does not match with either of three alternative forms')
            else
              if feminine_name.blank?
                soft_validations.add(:feminine_name, "The species name is marked as #{part_of_speech_name}, but the name spelling in feminine is not provided")
              else
                e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Feminine, feminine_name)
                soft_validations.add(:feminine_name, "Name has a non feminine ending: -#{e}") unless e.nil?
              end

              if masculine_name.blank?
                soft_validations.add(:masculine_name, "The species name is marked as #{part_of_speech_name}, but the name spelling in masculine is not provided")
              else
                e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Masculine, masculine_name)
                soft_validations.add(:masculine_name, "Name has a non masculine ending: -#{e}") unless e.nil?
              end

              if neuter_name.blank?
                soft_validations.add(:neuter_name, "The species name is marked as #{part_of_speech_name}, but the name spelling in neuter is not provided")
              else
                e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Neuter, neuter_name)
                soft_validations.add(:neuter_name, "Name has a non neuter ending: -#{e}") unless e.nil?
              end
            end
          end
        end
      end
    end

    def sv_species_gender_agreement_not_required
      if is_species_rank? && ((!feminine_name.blank? || !masculine_name.blank? || !neuter_name.blank?)) && is_available?
        s = part_of_speech_name
        if !s.nil? && !%w{adjective participle}.include?(s)
          soft_validations.add(:feminine_name, 'Alternative spelling is not required for the name which is not adjective or participle.') unless feminine_name.blank?
          soft_validations.add(:masculine_name, 'Alternative spelling is not required for the name which is not adjective or participle.')  unless masculine_name.blank?
          soft_validations.add(:neuter_name, 'Alternative spelling is not required for the name which is not adjective or participle.')  unless neuter_name.blank?
        end
      end
    end

#    def sv_validate_coordinated_names
#      return true unless is_available?
#      r = self.iczn_set_as_incorrect_original_spelling_of_relationship
#      list_of_coordinated_names.each do |t|
#        soft_validations.add(:base, "The original publication does not match with the original publication of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Original publication was updated') if self.source && t.source && self.source.id != t.source.id
#        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Author was updated') unless self.verbatim_author == t.verbatim_author
#        soft_validations.add(:year_of_publication, "The year of publication does not match with the year of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Year was updated') unless self.year_of_publication == t.year_of_publication
#        soft_validations.add(:base, "The gender status does not match with the gender of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Gender was updated') if rank_string =~ /Genus/ && self.gender_class != t.gender_class && !has_misspelling_relationship?
#        soft_validations.add(:base, "The part of speech status does not match with the part of speech of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Gender was updated') if rank_string =~ /Species/ && self.part_of_speech_class != t.part_of_speech_class && !has_misspelling_relationship?
#        soft_validations.add(:base, "The original genus does not match with the original genus of coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Original genus was updated') if self.original_genus != t.original_genus && r.blank?
#        soft_validations.add(:base, "The original subgenus does not match with the original subgenus of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Original subgenus was updated') if self.original_subgenus != t.original_subgenus && r.blank?
#        soft_validations.add(:base, "The original species does not match with the original species of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Original species was updated') if self.original_species != t.original_species && r.blank?
#        soft_validations.add(:base, "The type species does not match with the type species of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Type species was updated') if self.type_species != t.type_species && !has_misspelling_relationship?
#        soft_validations.add(:base, "The type genus does not match with the type genus of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Type genus was updated') if self.type_genus != t.type_genus && !has_misspelling_relationship?
#        soft_validations.add(:base, "The type specimen does not match with the type specimen of the coordinated #{t.rank_class.rank_name}",
#                             fix: :sv_fix_coordinated_names, success_message: 'Type specimen was updated') if !self.has_same_primary_type(t) && !has_misspelling_relationship?
#        sttnr = self.type_taxon_name_relationship
#        tttnr = t.type_taxon_name_relationship
#        unless sttnr.nil? || tttnr.nil?
#          soft_validations.add(:base, "The type species relationship does not match with the type species relationship of the coordinated #{t.rank_class.rank_name}",
#                               fix: :sv_fix_coordinated_names, success_message: 'Type species relationship was updated') unless sttnr.type == tttnr.type
#        end
#      end
#    end

    def sv_validate_coordinated_names_source
      return true unless is_available?
      s = self.source
      list_of_coordinated_names.each do |t|
        if ((s && t.source && s.id != t.source.id) || (s.nil? && t.source))
          soft_validations.add(:base, "The original publication does not match with the original publication of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_source, success_message: 'Original publication was updated')
        end
      end
    end

    def sv_fix_coordinated_names_source
      fixed = false
      return false unless self.source.nil?
        list_of_coordinated_names.each do |t|
          if !t.source.nil?
            self.source = t.source
            fixed = true
          end
        end
        if fixed
        begin
          Protonym.transaction do
            self.source.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_author
      s = self.verbatim_author
      list_of_coordinated_names.each do |t|
        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_author, success_message: 'Author was updated') unless s == t.verbatim_author
      end
    end

    def sv_fix_coordinated_names_author
      return false unless self.verbatim_author.nil?
      list_of_coordinated_names.each do |t|
        if self.verbatim_author.nil? && !t.verbatim_author.nil?
          self.update_column(:verbatim_author, t.verbatim_author)
          return true
        end
      end
      return false
    end

    def sv_validate_coordinated_names_year
      s = self.year_of_publication
      list_of_coordinated_names.each do |t|
        soft_validations.add(:year_of_publication, "The year of publication does not match with the year of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_year, success_message: 'Year was updated') unless s == t.year_of_publication
      end
    end

    def sv_fix_coordinated_names_year
      return false unless self.year_of_publication.nil?
      list_of_coordinated_names.each do |t|
        if self.year_of_publication.nil? && !t.year_of_publication.nil?
          self.update_column(:year_of_publication, t.year_of_publication)
          return true
        end
      end
      return false
    end

    def sv_validate_coordinated_names_gender
      return true unless is_available?
      return true unless is_genus_rank?
      s = self.gender_class
      list_of_coordinated_names.each do |t|
        if s != t.gender_class
          soft_validations.add(:base, "The gender status does not match with that of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_gender, success_message: 'Gender was updated')
        end
      end
    end

    def sv_fix_coordinated_names_gender
      return false unless self.gender_class.nil?
      list_of_coordinated_names.each do |t|
        unless t.gender_class.nil?
          c = self.taxon_name_classifications.create(type: t.gender_class.to_s)
          return true if c.id
        end
      end
      return false
    end

    def sv_validate_coordinated_names_part_of_speach
      return true unless is_available?
      return true unless is_species_rank?
      list_of_coordinated_names.each do |t|
        if self.part_of_speech_class != t.part_of_speech_class
          soft_validations.add(:base, "The part of speech status does not match with that of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_part_of_speach, success_message: 'Part of speech was updated')
        end
      end
    end

    def sv_fix_coordinated_names_part_of_speach
      return false unless self.part_of_speech_class.nil?
      list_of_coordinated_names.each do |t|
        unless t.part_of_speech_class.nil?
          c = self.taxon_name_classifications.create(type: t.part_of_speech_class.to_s)
          return true if c.id
        end
      end
      return false
    end

    def sv_validate_coordinated_names_original_genus
      return true if !is_genus_or_species_rank? || !is_available?
      list_of_coordinated_names.each do |t|
        if self.original_genus.try(:name) != t.original_genus.try(:name)
          soft_validations.add(:base, "The original genus does not match with the original genus of coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_original_genus, success_message: 'Original genus was updated')
        end
      end
    end

    def sv_fix_coordinated_names_original_genus
      fixed = false
      return false unless self.original_genus.nil?
      list_of_coordinated_names.each do |t|
        if !t.original_genus.nil?
          self.original_genus = t.original_genus
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_original_subgenus
      return true if !is_genus_or_species_rank? || has_misspelling_relationship?
      list_of_coordinated_names.each do |t|
        if self.original_subgenus.try(:name) != t.original_subgenus.try(:name)
          soft_validations.add(:base, "The original subgenus does not match with the original subgenus of coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_original_subgenus, success_message: 'Original subgenus was updated')
        end
      end
    end

    def sv_fix_coordinated_names_original_subgenus
      fixed = false
      return false unless self.original_subgenus.nil?
      list_of_coordinated_names.each do |t|
        if !t.original_subgenus.nil?
          self.original_subgenus = t.original_subgenus
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_original_species
      return true if !is_species_rank? || has_misspelling_relationship?
      list_of_coordinated_names.each do |t|
        if self.original_species.try(:name) != t.original_species.try(:name)
          soft_validations.add(:base, "The original species does not match with the original species of coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_original_species, success_message: 'Original species was updated')
        end
      end
    end

    def sv_fix_coordinated_names_original_species
      fixed = false
      return false unless self.original_species.nil?
      list_of_coordinated_names.each do |t|
        if !t.original_species.nil?
          self.original_species = t.original_species
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_original_subspecies
      return true if !is_species_rank? || has_misspelling_relationship?
      list_of_coordinated_names.each do |t|
        if self.original_subspecies.try(:name) != t.original_subspecies.try(:name)
          soft_validations.add(:base, "The original subspecies does not match with the original subspecies of coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_original_subspecies, success_message: 'Original subspecies was updated')
        end
      end
    end

    def sv_fix_coordinated_names_original_subspecies
      fixed = false
      return false unless self.original_subspecies.nil?
      list_of_coordinated_names.each do |t|
        if !t.original_subspecies.nil?
          self.original_subspecies = t.original_subspecies
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_original_variety
      return true if !is_species_rank? || has_misspelling_relationship?
      list_of_coordinated_names.each do |t|
        if self.original_variety.try(:name) != t.original_variety.try(:name)
          soft_validations.add(:base, "The original variety does not match with the original variety of coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_original_variety, success_message: 'Original variety was updated')
        end
      end
    end

    def sv_fix_coordinated_names_original_variety
      fixed = false
      return false unless self.original_variety.nil?
      list_of_coordinated_names.each do |t|
        if !t.original_variety.nil?
          self.original_variety = t.original_variety
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_original_form
      return true if !is_species_rank? || has_misspelling_relationship?
      list_of_coordinated_names.each do |t|
        if self.original_form.try(:name) != t.original_form.try(:name)
          soft_validations.add(:base, "The original form does not match with the original form of coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_original_form, success_message: 'Original form was updated')
        end
      end
    end

    def sv_fix_coordinated_names_original_form
      fixed = false
      return false unless self.original_form.nil?
      list_of_coordinated_names.each do |t|
        if !t.original_form.nil?
          self.original_form = t.original_form
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_type_species
      return true unless is_available?
      return true unless is_genus_rank?
      list_of_coordinated_names.each do |t|
        if self.type_species != t.type_species
          soft_validations.add(:base, "The type species does not match with the type species of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_type_species, success_message: 'Type species was updated')
        end
      end
    end

    def sv_fix_coordinated_names_type_species
      fixed = false
      return false unless self.type_species.nil?
      list_of_coordinated_names.each do |t|
        if !t.type_species.nil?
          self.type_species = t.type_species
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.type_species.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_type_species_type
      return true unless is_genus_rank?
      sttnr = self.type_taxon_name_relationship
      return true if sttnr.nil?
      list_of_coordinated_names.each do |t|
        tttnr = t.type_taxon_name_relationship
        if !tttnr.nil? && sttnr.type != tttnr.type
          soft_validations.add(:base, "The type species relationship does not match with the type species relationship of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_type_species_type, success_message: 'Type species relationship was updated')
        end
      end
    end

    def sv_fix_coordinated_names_type_species_type
      sttnr = self.type_taxon_name_relationship
      return false if sttnr.nil?
      fixed = false
      list_of_coordinated_names.each do |t|
        tttnr = t.type_taxon_name_relationship
        if !tttnr.nil? && sttnr.type != tttnr.type && sttnr.type.safe_constantize.descendants.collect{|i| i.to_s}.include?(tttnr.type.to_s)
          self.type_taxon_name_relationship.type = t.type_taxon_name_relationship.type
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.type_taxon_name_relationship.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_type_genus
      return true unless is_available?
      return true unless is_family_rank?
      list_of_coordinated_names.each do |t|
        if self.type_genus != t.type_genus
          soft_validations.add(:base, "The type genus does not match with the type genus of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_type_genus, success_message: 'Type genus was updated')
        end
      end
    end

    def sv_fix_coordinated_names_type_genus
      fixed = false
      return false unless self.type_genus.nil?
      list_of_coordinated_names.each do |t|
        if !t.type_genus.nil?
          self.type_genus = t.type_genus
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.type_genus.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_type_specimen
      return true if !is_species_rank? || !is_available?
      list_of_coordinated_names.each do |t|
        if !self.has_same_primary_type(t)
          soft_validations.add(:base, "The type specimen does not match with the type specimen of the coordinate #{t.rank_class.rank_name}", fix: :sv_fix_coordinated_names_type_specimen, success_message: 'The type specimen was updated')
        end
      end
    end

    def sv_fix_coordinated_names_type_specimen
      fixed = false
      return false unless self.get_primary_type.empty?
      list_of_coordinated_names.each do |t1|
        types2 = t1.get_primary_type
        if !types2.empty?
          new_type_material = []
          types2.each do |t|
            new_type_material.push({type_type: t.type_type, protonym_id: self.id, collection_object_id: t.collection_object_id, source: t.source})
          end
          self.type_materials.build(new_type_material)
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.save
          end
          return true
        rescue
          return false
        end
      end
    end

=begin
    def sv_fix_coordinated_names
      fixed = false
      gender = self.gender_class
      speech = self.part_of_speech_class

      list_of_coordinated_names.each do |t|
        if t.source.nil? && !t.source.nil?
          self.source = t.source
          fixed = true
        end

        if self.verbatim_author.nil? && !t.verbatim_author.nil?
          self.verbatim_author = t.verbatim_author
          fixed = true
        end

        if self.year_of_publication.nil? && !t.year_of_publication.nil?
          self.year_of_publication = t.year_of_publication
          fixed = true
        end

        t_gender = t.gender_class

        if gender.nil? && !t_gender.nil?
          self.taxon_name_classifications.build(type: t_gender.to_s)
          fixed = true
        end

        t_speech = t.part_of_speech_class

        if speech.nil? && speech != t_speech
          self.taxon_name_classifications.build(type: t_speech.to_s)
          fixed = true
        end

        if self.gender_class.nil? && !t.gender_class.nil?
          self.taxon_name_classifications.build(type: t.gender_class.to_s)
          fixed = true
        end

        if self.original_genus.nil? && !t.original_genus.nil?
          self.original_genus = t.original_genus
          fixed = true
        end

        if self.original_subgenus.nil? && !t.original_subgenus.nil?
          self.original_subgenus = t.original_subgenus
          fixed = true
        end

        if self.original_species.nil? && !t.original_species.nil?
          self.original_species = t.original_species
          fixed = true
        end

        if self.original_subspecies.nil? && !t.original_subspecies.nil?
          self.original_subspecies = t.original_subspecies
          fixed = true
        end

        if self.type_species.nil? && !t.type_species.nil?
          self.type_species = t.type_species
          fixed = true
        end

        if self.type_genus.nil? && !t.type_genus.nil?
          self.type_genus = t.type_genus
          fixed = true
        end

        types1 = self.get_primary_type
        types2 = t.get_primary_type
        if types1.empty? && !types2.empty?
          new_type_material = []
          types2.each do |t|
            new_type_material.push({type_type: t.type_type, protonym_id: t.protonym_id, collection_object_id: t.collection_object_id, source: t.source})
          end
          self.type_materials.build(new_type_material)
          fixed = true
        end

        sttnr = self.type_taxon_name_relationship
        tttnr = t.type_taxon_name_relationship
        unless sttnr.nil? || tttnr.nil?
          if sttnr.type != tttnr.type && sttnr.type.safe_constantize.descendants.collect{|i| i.to_s}.include?(tttnr.type.to_s)
            self.type_taxon_name_relationship.type = t.type_taxon_name_relationship.type
            fixed = true
          end
        end
      end

      if fixed
        begin
          Protonym.transaction do
            self.save
          end
        rescue
          return false
        end
      end
      return fixed
    end
=end

    def sv_type_placement
      # type of this taxon is not included in this taxon
      if !!self.type_taxon_name
        soft_validations.add(:base, "#{self.rank_class.rank_name} #{self.cached_html} has the type #{self.type_taxon_name.rank_class.rank_name} #{self.type_taxon_name.cached_html} classified outside of this taxon") unless self.type_taxon_name.get_valid_taxon_name.ancestors.include?(TaxonName.find(self.cached_valid_taxon_name_id))
      end
    end

    def sv_type_placement1
      # this taxon is a type, but not included in nominal taxon
      if !!self.type_of_taxon_names
        self.type_of_taxon_names.each do |t|
          soft_validations.add(:base, "#{self.rank_class.rank_name.capitalize} #{self.cached_html} is the type of #{t.rank_class.rank_name} #{t.cached_html} but it has a parent outside of #{t.cached_html}") unless self.get_valid_taxon_name.ancestors.include?(TaxonName.find(t.cached_valid_taxon_name_id))
        end
      end
    end

    def sv_primary_types
      if is_species_rank? && is_available?
        if self.type_materials.primary.empty? && self.type_materials.syntypes.empty?
          soft_validations.add(:base, 'Primary type is not selected')
        elsif self.type_materials.primary.count > 1 || (!self.type_materials.primary.empty? && !self.type_materials.syntypes.empty?)
          soft_validations.add(:base, 'More than one of primary types are selected. Uncheck the specimens which are not primary types for this taxon')
        end
      end
    end

    def sv_primary_types_repository
      if is_species_rank?
        s = self.type_materials
        unless s.empty?
          s.primary.each do |t|
            soft_validations.add(:base, 'Primary type repository is not set') if t.collection_object.try(:repository).nil?
          end
          s.syntypes.each do |t|
            soft_validations.add(:base, 'Syntype repository is not set') if t.collection_object.try(:repository).nil?
          end
        end
      end
    end

    def sv_single_sub_taxon
      if self.rank_class
        rank = rank_string
        if rank != 'potentially_validating rank' && self.rank_class.nomenclatural_code == :iczn && %w(subspecies subgenus subtribe tribe subfamily).include?(self.rank_class.rank_name)
          sisters = self.parent.descendants.with_rank_class(rank).select{|t| t.id == t.cached_valid_taxon_name_id}
          if rank =~ /Family/
            z = Protonym.family_group_base(self.name)
            search_name = z.nil? ? nil : Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i}
            a = sisters.collect{|i| Protonym.family_group_base(i.name) }
            sister_names = a.collect{|z| Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i} }.flatten
          else
            search_name = [self.name]
            sister_names = sisters.collect{|i| i.name }
          end
          if search_name.include?(self.parent.name) && sisters.count == 1
            soft_validations.add(:base, "#{self.cached_html} is a single #{self.rank_class.rank_name} in the nominal #{self.parent.rank_class.rank_name} #{self.parent.cached_html}")
          elsif !sister_names.include?(self.parent.name) && !sisters.empty? && self.parent.name == Protonym.family_group_base(self.parent.name) && rank =~ /Family/
            # do nothing
          elsif !sister_names.include?(self.parent.name) && !sisters.empty?
            soft_validations.add(:base, "The parent #{self.parent.rank_class.rank_name} #{self.parent.cached_html} of this #{self.rank_class.rank_name} does not contain nominotypical #{self.rank_class.rank_name} #{self.parent.name}",
                                 fix: :sv_fix_add_nominotypical_sub, success_message: "Nominotypical #{self.rank_class.rank_name} #{self.parent.name} was added to nominal #{self.parent.rank_class.rank_name} #{self.parent.name}")
          end
        end
      end
    end

    def sv_fix_add_nominotypical_sub
      rank  = rank_string
      p     = self.parent
      prank = p.rank_string
      if (rank =~ /Family/ && prank =~ /Family/) || (rank =~ /Genus/ && prank =~ /Genus/) || (rank =~ /Species/ && prank =~ /Species/)
        begin
          Protonym.transaction do
            if rank =~ /Family/ && prank =~ /Family/
              name = Protonym.family_group_base(self.parent.name)
              case self.rank_class.rank_name
              when 'subfamily'
                name += 'inae'
              when 'tribe'
                name += 'ini'
              when 'subtribe'
                name += 'ina'
              end
            else
              name = p.name
            end

            t = Protonym.new(name: name, rank_class: rank, verbatim_author: p.verbatim_author, year_of_publication: p.year_of_publication, source: p.source, parent: p)
            t.save
            t.soft_validate
            t.fix_soft_validations
            return true
          end
        rescue ActiveRecord::RecordInvalid # naked rescue is very bad
          return false
        end
      end
    end

    def sv_parent_priority
      if self.rank_class
        rank_group = self.rank_class.parent
        parent = self.parent

        if !is_higher_rank? && parent && rank_group == parent.rank_class.parent
          unless unavailable_or_invalid?
            date1 = self.nomenclature_date
            date2 = parent.nomenclature_date
            unless date1.nil? || date2.nil?
              if date1 < date2
                soft_validations.add(:base, "#{self.rank_class.rank_name.capitalize} #{self.cached_html_name_and_author_year} should not be older than parent #{parent.rank_class.rank_name} #{parent.cached_html_name_and_author_year}")
              end
            end
          end
        end
      end
    end

    def sv_homotypic_synonyms
      unless unavailable_or_invalid?
        if self.id == self.lowest_rank_coordinated_taxon.id
          possible_synonyms = []
          if rank_string =~ /Species/
            primary_types = self.get_primary_type
            unless primary_types.empty?
              p                 = primary_types.collect {|t| t.collection_object_id}
              possible_synonyms = Protonym.with_type_material_array(p).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_project(self.project_id)
#              possible_synonyms = Protonym.with_type_material_array(p).that_is_valid.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_project(self.project_id)
            end
          elsif rank_string =~ /Family/ && self.name == Protonym.family_group_base(self.name)
            # do nothing
          else
            type = self.type_taxon_name
            unless type.nil?
              possible_synonyms = Protonym.with_type_of_taxon_names(type.id).not_self(self).with_project(self.project_id)
#              possible_synonyms = Protonym.with_type_of_taxon_names(type.id).that_is_valid.not_self(self).with_project(self.project_id)
            end
          end

          possible_synonyms = reduce_list_of_synonyms(possible_synonyms)
          possible_synonyms.each do |s|
            soft_validations.add(:base, "Missing relationship: #{self.rank_class.rank_name} #{self.cached_html} should be a synonym of #{s.cached_html} #{s.cached_author_year} since they share the same type")
          end
        end
      end
    end

    def sv_potential_family_homonyms
      if persisted? && is_family_rank? && is_available?
        if TaxonNameRelationship.where_subject_is_taxon_name(self).homonym_or_suppressed.empty?
          if self.id == self.lowest_rank_coordinated_taxon.id
#            name1 = self.cached_primary_homonym ? self.cached_primary_homonym : nil
#            possible_primary_homonyms = name1 ? Protonym.with_primary_homonym(name1).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).without_homonym_or_suppressed.not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::FamilyGroup').with_project(self.project_id) : []
#            list1 = reduce_list_of_synonyms(possible_primary_homonyms)
#            if !list1.empty?
#              list1.each do |s|
#                soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a homonym or duplicate of #{s.cached_html_name_and_author_year}")
#              end
#            else
              name2 = self.cached_primary_homonym_alternative_spelling ? self.cached_primary_homonym_alternative_spelling : nil
              possible_primary_homonyms_alternative_spelling = name2 ? Protonym.with_primary_homonym_alternative_spelling(name2).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::FamilyGroup').with_project(self.project_id) : []
              list2 = reduce_list_of_synonyms(possible_primary_homonyms_alternative_spelling)
              if !list2.empty?
                list2.each do |s|
                  soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a homonym or duplicate of #{s.cached_html_name_and_author_year}")
                end
              end
 #           end
          end
        end
      end
    end

    def sv_family_is_invalid
      if persisted? && is_family_rank? && is_available?
        tg = type_genus
        if tg && (!TaxonNameRelationship.where_subject_is_taxon_name(tg).homonym_or_suppressed.empty? ||
            !TaxonNameClassification.where_taxon_name(tg).with_type_string('TaxonNameClassification::Iczn::Available::Invalid::Homonym').empty? )
          if self.id == self.lowest_rank_coordinated_taxon.id
            if TaxonNameClassification.where_taxon_name(self).with_type_base('TaxonNameClassification::Iczn::Available::Invalid').empty?
              soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} is invalid due to the homonymy or suppression of its type genus")
            end
          end
        end
      end
    end

    def sv_family_is_invalid_no_substitute
      if persisted? && is_family_rank? && self.id == self.lowest_rank_coordinated_taxon.id
        if !TaxonNameClassification.where_taxon_name(self).with_type_base('TaxonNameClassification::Iczn::Available::Invalid').empty?
          if self.iczn_set_as_synonym_of.nil?
            soft_validations.add(:base, 'Missing relationship: The name is invalid, but a substitute name is not selected')
          end
        end
      end
    end

    def sv_potential_genus_homonyms
      if persisted? && is_genus_rank? && is_available?
        if TaxonNameRelationship.where_subject_is_taxon_name(self).homonym_or_suppressed.empty?
          if self.id == self.lowest_rank_coordinated_taxon.id
            name1 = self.cached_primary_homonym ? self.cached_primary_homonym : nil
            possible_primary_homonyms = name1 ? Protonym.with_primary_homonym(name1).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).without_homonym_or_suppressed.not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::GenusGroup').with_project(self.project_id) : []
            list1 = reduce_list_of_synonyms(possible_primary_homonyms)
            if !list1.empty?
              list1.each do |s|
                soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a homonym or duplicate of #{s.cached_html_name_and_author_year}")
              end
            end
          end
        end
      end
    end

    def sv_potential_species_homonyms
      if persisted? && is_species_rank? && is_available?
        if TaxonNameRelationship.where_subject_is_taxon_name(self).homonym_or_suppressed.empty?
          if self.id == self.lowest_rank_coordinated_taxon.id
            name1 = self.cached_primary_homonym ? self.cached_primary_homonym : nil
            possible_primary_homonyms = name1 ? Protonym.with_primary_homonym(name1).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).without_homonym_or_suppressed.not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::SpeciesGroup').with_project(self.project_id) : []
            list1 = reduce_list_of_synonyms(possible_primary_homonyms)
            if !list1.empty?
              list1.each do |s|
                soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a primary homonym or duplicate of #{s.cached_html_name_and_author_year}")
                #  fix: :sv_fix_add_relationship('iczn_set_as_primary_homonym_of'.to_sym, s.id),
                #  success_message: 'Primary homonym relationship was added',
                #  failure_message: 'Fail to add a relationship')
              end
            else
              name2 = self.cached_primary_homonym_alternative_spelling ? self.cached_primary_homonym_alternative_spelling : nil
              possible_primary_homonyms_alternative_spelling = name2 ? Protonym.with_primary_homonym_alternative_spelling(name2).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::SpeciesGroup').with_project(self.project_id) : []
              list2 = reduce_list_of_synonyms(possible_primary_homonyms_alternative_spelling)
              if !list2.empty?
                list2.each do |s|
                  soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} could be a primary homonym of #{s.cached_html_name_and_author_year} (alternative spelling)")
                end
              else
                name3 = self.cached_secondary_homonym ? self.cached_secondary_homonym : nil
                possible_secondary_homonyms = name3 ? Protonym.with_secondary_homonym(name3).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::SpeciesGroup').with_project(self.project_id) : []
                list3 = reduce_list_of_synonyms(possible_secondary_homonyms)
                if !list3.empty?
                  list3.each do |s|
                    soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a secondary homonym or duplicate of #{s.cached_html_name_and_author_year}")
                  end
                else
                  name4 = self.cached_secondary_homonym ? self.cached_secondary_homonym_alternative_spelling : nil
                  possible_secondary_homonyms_alternative_spelling = name4 ? Protonym.with_secondary_homonym_alternative_spelling(name4).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class('NomenclaturalRank::Iczn::SpeciesGroup').with_project(self.project_id) : []
                  list4 = reduce_list_of_synonyms(possible_secondary_homonyms_alternative_spelling)
                  if !list4.empty?
                    list4.each do |s|
                      soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} could be a secondary homonym of #{s.cached_html_name_and_author_year} (alternative spelling)")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    def sv_missing_original_genus
      if is_genus_or_species_rank? && self.original_genus.nil?
        soft_validations.add(:base, 'Missing relationship: Original genus is not selected')
      end
    end

    def sv_original_combination_relationships
      relationships = self.original_combination_relationships
      unless relationships.empty?
        relationships = relationships.sort_by{|r| r.type_class.order_index }
        ids = relationships.collect{|r| r.subject_taxon_name_id}
        if !ids.include?(self.id)
          if (list_of_coordinated_names.collect{|r| r.id} & ids).empty?
            soft_validations.add(:base, "Missing relationship: The original rank of #{self.cached_html} is not specified in the original combination.")
          end
        elsif ids.last != self.id
          soft_validations.add(:base, "Invalid original combination relationship: #{self.cached_html} should be moved to the lowest rank")
        end
      end
    end

    # @proceps: this is not fixable given this logic only
    def sv_missing_author
      if self.author_string.nil? && is_available?
        soft_validations.add(
          :verbatim_author, 'Author is missing',
          #  fix: :sv_fix_missing_author,
          success_message: 'Author was updated')
      end
    end

    # @proceps: TODO: was not fixable
    def sv_missing_year
      if self.year_integer.nil? && is_available?
        soft_validations.add(:year_of_publication, 'Year is missing', success_message: 'Year was updated')
      end
    end

    def sv_missing_etymology
      if self.etymology.nil? && self.rank_string =~ /(Genus|Species)/ && is_available?
        z = TaxonName.
            where(name: name, project_id: project_id).where.not(etymology: nil).
            group(:etymology).
            count(:etymology)

        if z.empty?
          soft_validations.add(:etymology, 'Etymology is missing')
        else
          z1 = z.sort_by {|k, v| -v}
          t = z1[0][1] == 1 ? 'time' : 'times'
          soft_validations.add(:etymology, "Etymology is missing. Previously used etymology for similar name: '#{z1[0][0]}' (#{z1[0][1]} #{t})")
        end
      end
    end

    def sv_extant_children
      unless self.parent_id.blank?
        if self.is_fossil?
          taxa = Protonym.where(parent_id: self.id)
          z = 0
          unless taxa.empty?
            taxa.each do |t|
              soft_validations.add(:base, "Extinct taxon #{self.cached_html} has extant children") if !t.is_fossil? && t.id == t.cached_valid_taxon_name_id && z == 0
              z = 1
            end
          end
        end
      end
    end

    def sv_protonym_to_combination
      if convertable_to_combination?
        soft_validations.add(
          :base, "Invalid #{self.cached_original_combination_html} could be converted into a Combination",
          fix: :becomes_combination,
          success_message: "Protonym #{self.cached_original_combination_html} was successfully converted into a combination",
          fix_trigger: :requested)
      end
    end

    def sv_missing_roles
      if self.roles.empty? && !has_misspelling_relationship? && !name_is_misapplied?
        soft_validations.add(:base, 'Taxon name author role is not selected')
      end
    end

    def sv_year_is_not_required
      if !self.year_of_publication.nil? && self.source && self.year_of_publication == self.source.year
        soft_validations.add(
          :year_of_publication, 'Year of publication is not required, it is derived from the source',
          fix: :sv_fix_year_is_not_required,
          success_message: 'Year of publication was deleted'
        )
      end
    end

    def sv_fix_year_is_not_required
      self.update_column(:year_of_publication, nil)
      return true
    end

    def sv_author_is_not_required
      if self.verbatim_author && (!self.roles.empty? || (self.source && self.verbatim_author == self.source.authority_name))
        soft_validations.add(
          :verbatim_author, 'Verbatim author is not required, it is derived from the source and taxon name author roles',
          fix: :sv_fix_author_is_not_required,
          success_message: 'Taxon name verbatim author was deleted')
      end
    end

    def sv_fix_author_is_not_required
      self.update_column(:verbatim_author, nil)
      return true
    end

    def sv_misspelling_roles_are_not_required
      if !self.roles.empty? && self.source && (has_misspelling_relationship? || name_is_misapplied?)
        soft_validations.add(
          :base, 'Taxon name author role is not required for misspellings and misapplications',
          fix: :sv_fix_misspelling_roles_are_not_required,
          success_message: 'Roles were deleted')
      end
    end

    def sv_fix_misspelling_roles_are_not_required
      self.roles.each do |r|
        r.destroy
      end
      return true
    end

    def sv_misspelling_author_is_not_required
      if self.verbatim_author && self.source && (has_misspelling_relationship? || name_is_misapplied?)
        soft_validations.add(
          :verbatim_author, 'Verbatim author is not required for misspellings and misapplications',
          fix: :sv_fix_misspelling_author_is_not_required,
          success_message: 'Verbatim author was deleted')
      end
    end

    def sv_fix_misspelling_author_is_not_required
      self.update_column(:verbatim_author, nil)
      return true
    end

    def sv_misspelling_year_is_not_required
      if self.year_of_publication && self.source && (has_misspelling_relationship? || name_is_misapplied?)
        soft_validations.add(
          :year_of_publication, 'Year is not required for misspellings and misapplications',
          fix: :sv_fix_misspelling_year_is_not_required,
          success_message: 'Year was deleted')
      end
    end

    def sv_fix_misspelling_year_is_not_required
      self.update_column(:year_of_publication, nil)
      return true
    end

    #  def sv_fix_add_relationship(method, object_id)
    #    begin
    #      Protonym.transaction do
    #        self.save
    #        return true
    #      end
    #    rescue
    #      return false
    #    end
    #  false
    #  end

  end
end


