module Protonym::SoftValidationExtensions
  
  module Klass
    VALIDATIONS = {
      sv_validate_name: {
          set: :validate_name,
          name: 'Validate name',
          description: 'Validate name format'
      },

      sv_missing_etymology: {
        set: :missing_fields,
        name: 'Missing etymology',
        description: 'Etymology is not defined'
      },

      sv_validate_parent_rank: {
        set: :validate_parent_rank,
        name: 'Inappropriate parent rank',
        description: 'Validates parent rank, for example suggesting "Incertae sedis" relationship for the species which has family as a parent taxon',
        resolution:  [:new_taxon_name_task]
      },

      sv_potential_family_homonyms: {
        set: :potential_homonyms,
        name: 'Potential family-group name homonyms',
        description: 'Detect potential homonyms or duplicates in the family-group names'
      },

      sv_potential_genus_homonyms: {
        set: :potential_homonyms,
        name: 'Potential genus-group name homonyms',
        description: 'Detect potential homonyms or duplicates in the genus-group names'
      },

      sv_potential_species_homonyms: {
        set: :potential_homonyms,
        name: 'Potential species-group name homonyms',
        description: 'Detect potential homonyms or duplicates in the species-group names'
      },

      sv_missing_original_genus: {
        set: :missing_relationships,
        name: 'Missing original genus',
        description: 'Get notification if the original genus is not set for the genus or species-group name',
        resolution:  [:new_taxon_name_task]
      },

      sv_missing_type_species: {
        set: :missing_relationships,
        name: 'Missing type species',
        description: 'Get notification if the type species is not set for the genus-group name',
        resolution:  [:new_taxon_name_task]
      },

      sv_missing_type_genus: {
        set: :missing_relationships,
        name: 'Missing type genus',
        description: 'Get notification if the type genus is not set for the family-group name',
        resolution:  [:new_taxon_name_task]
      },

      sv_missing_substitute_name: {
        set: :missing_relationships,
        name: 'Missing substitute name',
        description: 'Get notification if the taxon is a homonym, but a synonym relationship is not provided'
      },

      sv_missing_part_of_speech: {
        set: :missing_classifications,
        name: 'Missing part of speech',
        description: 'Part of speech is not set for the species-group name',
        resolution:  [:new_taxon_name_task]
      },

      sv_missing_gender: {
        set: :missing_classifications,
        name: 'Missing grammatical gender',
        description: 'Grammatical gender is not set for the genus-group name',
        resolution:  [:new_taxon_name_task]
      },

      sv_species_gender_agreement: {
        set: :species_gender_agreement,
        name: 'Species gender agreement',
        description: 'Species-group names is set as declinable, but the form of name is not provided, or the ending of the name is incorrect'
      },

      sv_species_gender_agreement_not_required: {
        set: :species_gender_agreement,
        name: 'Species gender agreement not required',
        description: 'Species-group name is not declanable, alternative forms are not required'
      },

      sv_type_placement: {
        set: :type_placement,
        name: 'Type placement',
        description: 'The type is classified outside the taxon. For example, the type species of the genus is not included in this genus'
      },

      sv_type_placement1: {
        set: :type_placement,
        fix: :sv_fix_type_placement1,
        name: 'Type outside of nominal taxon',
        description: 'Notify if the taxon is a type, but not classified in the taxon, for which it is a type. For example, the type species of the genus is not included in this genus'
      },

      sv_primary_types: {
        set: :primary_types,
        name: 'Primary type is not selected',
        description: 'Primary type is not selected for a species-group taxon',
        resolution: [:edit_type_material_task]
      },

      sv_primary_types_repository: {
        set: :primary_types,
        name: 'Primary type repository is not selected',
        description: 'Species-group name has a primary type selected, but is does not have type repository',
        resolution: [:edit_type_material_task]
      },

      sv_validate_coordinated_names_source: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_source,
        name: 'Matching original source of coordinated names',
        description: 'Two coordinated names (for example a genus and nominotypical subgenus) should have the same original source. When the source is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_page: {
          set: :validate_coordinated_names,
          fix: :sv_fix_coordinated_names_page,
          name: 'Matching source papes of coordinate names',
          description: 'Two coordinate names (for example a genus and nominotypical subgenus) should have the same original citation pages. When the pages are not set for one of the names, they could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_author: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_author,
        name: 'Matching author of coordinated names',
        description: 'Two coordinated names (for example a genus and nominotypical subgenus) should have the same verbatim_author. When the author is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_year: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_year,
        name: 'Matching year of coordinated names',
        description: 'Two coordinated names (for example a genus and nominotypical subgenus) should have the same verbatim. When the year is not set for one of the names, it could be automatically set using the Fix',
        resolution: [:new_taxon_name_task],
      },

      sv_validate_coordinated_names_gender: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_gender,
        name: 'Matching gender of coordinated names',
        description: 'Two coordinated genus-group names (for example a genus and nominotypical subgenus) should have the same grammatical gender. When the gender is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_part_of_speech: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_part_of_speech,
        name: 'Matching part of speech of coordinated names',
        description: 'Two coordinated species-group names (for example a species and nominotypical subspecies) should have the same part of speech. When the part of speech is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_original_genus: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_original_genus,
        name: 'Matching original genus of coordinated names',
        description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same original genus. When the original genus is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_original_subgenus: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_original_subgenus,
        name: 'Matching original subgenus of coordinated names',
        description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same original subgenus. When the original subgenus is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_original_species: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_original_species,
        name: 'Matching original species of coordinated names',
        description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same original species. When the original species is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_original_subspecies: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_original_subspecies,
        name: 'Matching original subspecies of coordinated names',
        description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same original subspecies. When the original subspecies is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_original_variety: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_original_variety,
        name: 'Matching original variety of coordinated names',
        description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same original variety. When the original variety is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_original_form: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_original_form,
        name: 'Matching original form of coordinated names',
        description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same original form. When the original form is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_type_species: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_type_species,
        name: 'Matching type species of coordinated names',
        description: 'Two coordinated genus-group names (for example a genus and nominotypical subgenus) should have the same type species. When the type species is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_type_species_type: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_type_species_type,
        name: 'Matching type species designation of coordinated names',
        description: 'Two coordinated genus-group names (for example a genus and nominotypical subgenus) should have the same type species designation. When the type species designation does not match with the coordinated name, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_type_genus: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_type_genus,
        name: 'Matching type genus of coordinated names',
        description: 'Two coordinated family-group names (for example a family and nominotypical subfamily) should have the same type genus. When the type genus is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_type_specimen: {
        set: :validate_coordinated_names,
        fix: :sv_fix_coordinated_names_type_specimen,
        name: 'Matching type specimen of coordinated names',
        description: 'Two coordinated species-group names (for example a species and nominotypical subspecies) should have the same type specimens. When the type specimen is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_etymology: {
          set: :validate_coordinated_names,
          fix: :sv_fix_coordinated_names_etymology,
          name: 'Matching etymology of coordinated names',
          description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the same etymology. When the etymology is not set for one of the names, it could be automatically set using the Fix'
      },

      sv_validate_coordinated_names_roles: {
          set: :validate_coordinated_roles,
          fix: :sv_fix_coordinated_names_roles,
          name: 'Matching author roles of coordinated names',
          description: 'Two coordinated names (for example a species and nominotypical subspecies) should have the author roles. When the roles are not set for one of the names, they could be automatically set using the Fix'
      },

      sv_single_sub_taxon: {
        set: :single_sub_taxon,
        fix: :sv_fix_add_nominotypical_sub,
        name: 'Single sub-taxon',
        description: 'When the name is a sub-taxon (for example a subgenus in genus) the parent taxon should have a nominotypical sub-taxon. When the nominotypical sub-taxon is missing, it could be automatically created using the Fix'
      },

      sv_parent_priority: {
        set: :parent_priority,
        name: 'Higher rank priority',
        description: 'In the same rank-group (for example, genus-group), the parent should be the oldest taxon'
      },

      sv_homotypic_synonyms: {
        set: :homotypic_synonyms,
        name: 'Missing homotypic synonym relationship',
        description: 'Two taxa should be homotypic synonyms if they share the same type'
      },

      sv_family_is_invalid: {
        set: :family_is_invalid,
        name: 'Invalid family',
        description: 'Family is invalid due to the homonymy or suppression of its type genus'
      },

      sv_family_is_invalid_no_substitute: {
        set: :family_is_invalid,
        name: 'No substitute for invalid family',
        description: 'Family is marked as invalid, but no synonym relationship is created'
      },

      sv_source_not_older_then_description: {
        set: :dates,
        name: 'Source year does not match Taxon verbatim_year',
        description: 'Source year does not match Taxon verbatim_year'
      },

      sv_original_combination_relationships: {
        set: :original_combination_relationships,
        name: 'Self original combination relationship',
        description: 'Taxon itself should be present as as the lowest original combination relationship',
        resolution: [:new_taxon_name_task]
      },

      sv_extant_children: {
        set: :extant_children,
        name: 'Extinct taxon has extant children taxa',
        description: 'Extinct taxon has extant children taxa'
      },

      sv_protonym_to_combination: {
        set: :protonym_to_combination,
        fix: :becomes_combination,
        name: 'Protonym with unavailable/invalid relationship which could potentially be converted into a combination',
        description: 'Detection of protonyms, which could be not synonym, but subsequent combinations of another protonym. The Fix could convert the protonym into combination. The Fix require manual trigger',
        flagged: true
      },

      sv_presence_of_combination: {
        set: :presence_of_combination,
        fix: :sv_fix_presence_of_combination,
        name: 'Missing subsequent combination.',
        description: 'Missing subsequent combination. Current classification of the taxon is different from original combination. The Fix require manual trigger',
        flagged: true
      },

      sv_missing_roles: {
        set: :missing_roles,
        name: 'Missing taxon author roles',
        description: 'Taxon author roles are not set',
        resolution:  [:new_taxon_name_task]
      },

      sv_person_vs_year_of_publication: {
        set: :person_vs_year_of_publication,
        name: 'The taxon author deceased',
        description: "The taxon year of description does not match with the author's years of life",
        resolution:  [:new_taxon_name_task]
      },

      sv_year_is_not_required: {
        set: :year_is_not_required,
        fix: :sv_fix_year_is_not_required,
        name: 'Verbatim year is not required',
        description: 'Verbatim year is not required if the original source is set and the source has year of publication. The Fix will delete the verbatim_year'
      },

      sv_author_is_not_required: {
        set: :author_is_not_required,
        fix: :sv_fix_author_is_not_required,
        name: 'Verbatim author is not required',
        description: 'Verbatim author is not required if the author roles are set. The Fix will delete the verbatim_author'
      },

      sv_misspelling_roles_are_not_required: {
        set: :roles_are_not_required,
        fix: :sv_fix_misspelling_roles_are_not_required,
        name: 'Author roles are not required for misspelling',
        description: 'Author roles are not required for misspelling. The author of the misspelling is inherited from the correctly spelled protonym. The Fix will delete the roles'
      },

      sv_misspelling_author_is_not_required: {
        set: :roles_are_not_required,
        fix: :sv_fix_misspelling_author_is_not_required,
        name: 'Verbatim author is not required for misspelling',
        description: 'Verbatim author is not required for misspelling. The author of the misspelling is inherited from the correctly spelled protonym. The Fix will delete the author'
      },

      sv_misspelling_year_is_not_required: {
        set: :roles_are_not_required,
        fix: :sv_fix_misspelling_year_is_not_required,
        name: 'Verbatim year is not required for misspelling',
        description: 'Verbatim year is not required for misspelling. The year of the misspelling is inherited from the correctly spelled protonym. The Fix will delete the year'
      },

      sv_missing_otu: {
        set: :missing_otu,
        fix: :sv_fix_misspelling_otu,
        name: 'Missing OTU',
        description: 'Missing OTU prevents proper migration to Catalog of Life'
      }
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

    def sv_validate_name
      correct_name_format = false

      if rank_class
        # TODO: name these Regexp somewhere
        # TODO: move pertinent checks to base of nomenclature Classes to manage them there
        if (name =~ /^[a-zA-Z]*$/) || # !! should reference NOT_LATIN
            (nomenclatural_code == :iczn && name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
            (nomenclatural_code == :icnp && name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
            (nomenclatural_code == :icn && name =~  /^[a-zA-Z]*-[a-zA-Z]*$/) ||
            (nomenclatural_code == :icn && name =~  /^[a-zA-Z]*\s×\s[a-zA-Z]*$/) ||
            (nomenclatural_code == :icn && name =~  /^[a-zA-Z]*\s×[a-zA-Z]*$/) ||
            (nomenclatural_code == :icn && name =~  /^×[a-zA-Z]*$/) ||
            (nomenclatural_code == :icvcn)
          correct_name_format = true
        end

        unless correct_name_format
          icvcn_species = (nomenclatural_code == :icvcn && self.rank_string =~ /Species/) ? true : nil
          if is_available? && icvcn_species.nil?
            soft_validations.add(:name, 'Name should not have spaces or special characters, unless it has a status of misspelling or original misspelling')
          end
        end
      end
    end

    def sv_validate_parent_rank
      if self.rank_class && self.id == self.cached_valid_taxon_name_id
        if rank_string == 'NomenclaturalRank' || self.parent&.rank_string == 'NomenclaturalRank' || !!self.iczn_uncertain_placement_relationship
          true
        elsif !self.rank_class&.valid_parents.include?(self.parent.rank_string)
          soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name}). The name should be marked as 'Incertae sedis'")
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

    def sv_missing_part_of_speech
      if is_species_rank? && self.part_of_speech_class.nil? && !has_misspelling_relationship? && is_available?

        z = TaxonNameClassification.
            joins(:taxon_name).
            where(taxon_names: { name: name, project_id: project_id }).
            where("taxon_name_classifications.type LIKE 'TaxonNameClassification::Latinized::PartOfSpeech%'").
            group(:type).
            count(:type)

        if z.empty?
          z = TaxonNameClassification.
              joins(:taxon_name).
              where(taxon_names: { name: name}).
              where("taxon_name_classifications.type LIKE 'TaxonNameClassification::Latinized::PartOfSpeech%'").
              group(:type).
              count(:type)
          other_project = ' in different projects'
        else
          other_project = ''
        end

        if z.empty?
          soft_validations.add(:base, 'Part of speech is not specified. Please select if the name is a noun or an adjective.')
        else
          l = []
          z.each do |key, value|
            l << (value == 1 ? " as '#{key.constantize.label}' #{value.to_s} time" : " as '#{key.constantize.label}' #{value.to_s} times")
          end
          soft_validations.add(:base, "Part of speech is not specified. The name was previously used#{other_project}" + l.join('; '))
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
              forms = predict_three_forms
              if feminine_name.blank?
                soft_validations.add(:feminine_name, "The species name is marked as #{part_of_speech_name}, but the name spelling in feminine is not provided")
              else
                # e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Feminine, feminine_name)
                # soft_validations.add(:feminine_name, "Name has a non feminine ending: -#{e}") unless e.nil?
                soft_validations.add(:feminine_name, "Feminine form does not match with predicted: #{forms[:feminine_name]}") if feminine_name != forms[:feminine_name]
              end

              if masculine_name.blank?
                soft_validations.add(:masculine_name, "The species name is marked as #{part_of_speech_name}, but the name spelling in masculine is not provided")
              else
                # e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Masculine, masculine_name)
                # soft_validations.add(:masculine_name, "Name has a non masculine ending: -#{e}") unless e.nil?
                soft_validations.add(:masculine_name, "Masculine form does not match with predicted: #{forms[:masculine_name]}") if masculine_name != forms[:masculine_name]
              end

              if neuter_name.blank?
                soft_validations.add(:neuter_name, "The species name is marked as #{part_of_speech_name}, but the name spelling in neuter is not provided")
              else
                # e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Neuter, neuter_name)
                # soft_validations.add(:neuter_name, "Name has a non neuter ending: -#{e}") unless e.nil?
                soft_validations.add(:neuter_name, "Neuter form does not match with predicted: #{forms[:neuter_name]}") if neuter_name != forms[:neuter_name]
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
          soft_validations.add(:base, "The original publication does not match with the original publication of the coordinate #{t.rank_class.rank_name}", success_message: 'Original publication was updated', failure_message:  'Failed to update original publication')
        end
      end
    end

    def sv_fix_coordinated_names_source
      fixed = false
      pg = nil
      return false unless self.source.nil?
        list_of_coordinated_names.each do |t|
          if !t.source.nil?
            self.source = t.source
            pg = t.origin_citation.pages
            fixed = true
          end
        end
        if fixed
        begin
          Protonym.transaction do
            self.source.save
            self.origin_citation.update_column(:pages, pg)
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_page
      return true unless is_available?
      s = self.origin_citation
      list_of_coordinated_names.each do |t|
        ts = t.origin_citation
        if s && ts && s.source_id == ts.source_id && (s.pages != ts.pages || (s.pages.nil? && !ts.pages.nil?))
          soft_validations.add(:base, "The original publication page does not match with the original publication page of the coordinate #{t.rank_class.rank_name}", success_message: 'Original publication pages were updated', failure_message: 'Original publication pages were not updated')
        end
      end
    end

    def sv_fix_coordinated_names_page
      fixed = false
      return false if self.origin_citation.nil? || !self.origin_citation.pages.nil?
      list_of_coordinated_names.each do |t|
        if !t.origin_citation.nil? && !t.origin_citation.pages.nil? && self.origin_citation.source_id == t.origin_citation.source_id
          self.origin_citation.pages = t.origin_citation.pages
          fixed = true
        end
      end
      if fixed
        begin
          Protonym.transaction do
            self.origin_citation.save
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
        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinate #{t.rank_class.rank_name}", success_message: 'Author was updated', failure_message:  'Failed to update author') unless s == t.verbatim_author
      end
    end

    def sv_fix_coordinated_names_author
      return false if !self.verbatim_author.nil? || !self.taxon_name_author_roles.empty?
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
        soft_validations.add(:year_of_publication, "The year of publication does not match with the year of the coordinate #{t.rank_class.rank_name}", success_message: 'Year was updated', failure_message:  'Failed to update year') unless s == t.year_of_publication
      end
    end

    def sv_fix_coordinated_names_year
      return false if !self.year_of_publication.nil? || !self.source.try(:year).nil?
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
          soft_validations.add(:base, "The gender status does not match with that of the coordinate #{t.rank_class.rank_name}", success_message: 'Gender was updated', failure_message:  'Failed to update gender')
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

    def sv_validate_coordinated_names_part_of_speech
      return true unless is_available?
      return true unless is_species_rank?
      list_of_coordinated_names.each do |t|
        if self.part_of_speech_class != t.part_of_speech_class
          soft_validations.add(:base, "The part of speech status does not match with that of the coordinate #{t.rank_class.rank_name}", success_message: 'Part of speech was updated', failure_message:  'Failed to update part of speech')
        end
      end
    end

    def sv_fix_coordinated_names_part_of_speech
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
          soft_validations.add(:base, "The original genus does not match with the original genus of coordinate #{t.rank_class.rank_name}", success_message: 'Original genus was updated', failure_message:  'Failed to update original genus')
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
          soft_validations.add(:base, "The original subgenus does not match with the original subgenus of coordinate #{t.rank_class.rank_name}", success_message: 'Original subgenus was updated', failure_message:  'Failed to update original subgenus')
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
          soft_validations.add(:base, "The original species does not match with the original species of coordinate #{t.rank_class.rank_name}", success_message: 'Original species was updated', failure_message:  'Failed to update original species')
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
          soft_validations.add(:base, "The original subspecies does not match with the original subspecies of coordinate #{t.rank_class.rank_name}", success_message: 'Original subspecies was updated', failure_message:  'Failed to update original subspecies')
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
          soft_validations.add(:base, "The original variety does not match with the original variety of coordinate #{t.rank_class.rank_name}", success_message: 'Original variety was updated', failure_message:  'Failed to update original variety')
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
          soft_validations.add(:base, "The original form does not match with the original form of coordinate #{t.rank_class.rank_name}", success_message: 'Original form was updated', failure_message:  'Failed to update original form')
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
          soft_validations.add(:base, "The type species does not match with the type species of the coordinate #{t.rank_class.rank_name}", success_message: 'Type species was updated', failure_message:  'Failed to update type species')
        end
      end
    end

    def sv_fix_coordinated_names_type_species
      fixed = false
      tr = nil
      return false unless self.type_species.nil?
      list_of_coordinated_names.each do |t|
        if !t.type_species.nil? && fixed == false
          tr = TaxonNameRelationship.new(type: t.type_species_relationship.type, subject_taxon_name_id: t.type_species_relationship.subject_taxon_name_id, object_taxon_name_id: self.id)
          fixed = true
        end
      end
      if fixed
        begin
          TaxonNameRelationship.transaction do
            tr.save
          end
          return true
        rescue
          return false
        end
      end
    end

    def sv_validate_coordinated_names_etymology
      return true unless is_available?
      list_of_coordinated_names.each do |t|
        if self.etymology != t.etymology
          soft_validations.add(:etymology, "The etymology does not match with the etymology of the coordinate #{t.rank_class.rank_name}", success_message: 'Etymology was updated', failure_message:  'Etymology was not updated')
        end
      end
    end

    def sv_fix_coordinated_names_etymology
      fixed = false
      return false unless self.etymology.blank?
      list_of_coordinated_names.each do |t|
        if !t.etymology.blank?
          self.etymology = t.etymology
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

    def sv_validate_coordinated_names_roles
      return true unless is_available?
      list_of_coordinated_names.each do |t|
        if self.taxon_name_author_roles.collect{|i| i.person_id} != t.taxon_name_author_roles.collect{|i| i.person_id}
          soft_validations.add(:base, "The author roles do not match with the author roles of the coordinate #{t.rank_class.rank_name}", success_message: 'Author roles were updated', failure_message:  'Author roles were not updated')
        end
      end
    end

    def sv_fix_coordinated_names_roles
      return false unless self.taxon_name_author_roles.empty?
      list_of_coordinated_names.each do |t|
        if !t.taxon_name_author_roles.empty?
          t.taxon_name_author_roles.each do |r|
            TaxonNameAuthor.create(person_id: r.person_id, role_object: self, position: r.position)
          end
          return true
        end
      end
      return false
    end

    def sv_validate_coordinated_names_type_species_type
      return true unless is_genus_rank?
      sttnr = self.type_taxon_name_relationship
      return true if sttnr.nil?
      list_of_coordinated_names.each do |t|
        tttnr = t.type_taxon_name_relationship
        if !tttnr.nil? && sttnr.type != tttnr.type
          soft_validations.add(:base, "The type species relationship does not match with the type species relationship of the coordinate #{t.rank_class.rank_name}", success_message: 'Type species relationship was updated', failure_message:  'Failed to update type species relationship')
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
          soft_validations.add(:base, "The type genus does not match with the type genus of the coordinate #{t.rank_class.rank_name}", success_message: 'Type genus was updated', failure_message:  'Failed to update type genus')
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
          soft_validations.add(:base, "The type specimen does not match with the type specimen of the coordinate #{t.rank_class.rank_name}", success_message: 'Type specimen was updated', failure_message:  'Failed to update type specimen')
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
          soft_validations.add(:base, "#{self.rank_class.rank_name.capitalize} #{self.cached_html} is the type of #{t.rank_class.rank_name} #{t.cached_html} but it has a parent outside of #{t.cached_html}",
                               success_message: 'Parent for type species was updated', failure_message: 'Parent for type species was not updated') unless self.get_valid_taxon_name.ancestors.include?(TaxonName.find(t.cached_valid_taxon_name_id))
        end
      end
    end

    def sv_fix_type_placement1
      self.type_of_taxon_names.each do |t|
        coordinated = t.lowest_rank_coordinated_taxon
        if self.parent_id != coordinated.id
          #          if t.id != coordinated.id && self.parent_id != coordinated.id
          begin
            Protonym.transaction do
              self.parent_id = coordinated.id
              self.save
            end
            return true
          rescue
            return false
          end
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
            soft_validations.add(:base, "The parent #{self.parent.rank_class.rank_name} #{self.parent.cached_html} of this #{self.rank_class.rank_name} does not contain nominotypical #{self.rank_class.rank_name} #{Protonym.family_group_name_at_rank(self.parent.name, self.rank_class.rank_name)}",
                                 success_message: "Nominotypical #{self.rank_class.rank_name} was added to nominal #{self.parent.rank_class.rank_name} #{self.parent.cached_html}", failure_message:  'Failed to create nomynotypical taxon')
          end
        end
      end
    end

    def sv_fix_add_nominotypical_sub
      return false if list_of_coordinated_names.collect{|r| r.id}.include?(parent_id)
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
          end
        rescue ActiveRecord::RecordInvalid # naked rescue is very bad
          return false
        end
        return true
      end
    end

    def sv_parent_priority
      if self.rank_class
        rank_group = self.rank_class.parent
        parent = self.parent

        if !is_higher_rank? && parent && rank_group == parent.rank_class.parent
          unless !is_valid? #  unavailable_or_invalid?
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
      unless !is_valid? # unavailable_or_invalid?
        if self.id == self.lowest_rank_coordinated_taxon.id
          possible_synonyms = []
          if rank_string =~ /Species/
            primary_types = self.get_primary_type
            unless primary_types.empty?
              p                 = primary_types.collect {|t| t.collection_object_id}
              possible_synonyms = Protonym.with_type_material_array(p).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_project(self.project_id)
            end
          elsif rank_string =~ /Family/ && self.name == Protonym.family_group_base(self.name)
            # do nothing
          else
            type = self.type_taxon_name
            unless type.nil?
              possible_synonyms = Protonym.with_type_of_taxon_names(type.id).not_self(self).with_project(self.project_id)
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
                soft_validations.add(:base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a homonym or duplicate of #{s.cached_html_name_and_author_year}") if s.nomenclatural_code == self.nomenclatural_code
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
                soft_validations.add(
                  :base, "Missing relationship: #{self.cached_html_name_and_author_year} should be a primary homonym or duplicate of #{s.cached_html_name_and_author_year}")
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
      if is_genus_or_species_rank? && self.original_genus.nil? && !not_binominal?
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

    def sv_missing_etymology
      if self.etymology.nil? && self.rank_string =~ /(Genus|Species)/ && is_available?
        z = TaxonName.
            where(name: name, project_id: project_id).where.not(etymology: nil).
            group(:etymology).
            count(:etymology)

        if z.empty?
          z = TaxonName.where(name: name).where.not(etymology: nil).group(:etymology).count(:etymology)
          other_project = ' in different projects'
        else
          other_project = ''
        end

        if z.empty?
          soft_validations.add(:etymology, 'Etymology is missing')
        else
          z1 = z.sort_by {|k, v| -v}
          t = z1[0][1] == 1 ? 'time' : 'times'
          soft_validations.add(:etymology, "Etymology is missing. Previously used etymology for similar name#{other_project}: '#{z1[0][0]}' (#{z1[0][1]} #{t})")
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
          :base, "Unavailable or Invalid #{self.cached_original_combination_html} could potentially be converted into a combination (Fix will try to convert protonym into combination)",
          success_message: "Protonym #{self.cached_original_combination_html} was successfully converted into a combination", failure_message:  'Failed to convert protonym into combination')
      end
    end

    def sv_missing_roles
      if self.taxon_name_author_roles.empty? && !has_misspelling_relationship? && !name_is_misapplied? && is_family_or_genus_or_species_rank?
        soft_validations.add(:base, 'Taxon name author role is not selected')
      end
    end

    def sv_person_vs_year_of_publication
      if self.cached_nomenclature_date
        year = self.cached_nomenclature_date.year
        self.taxon_name_author_roles.each do |r|
          person = r.person
          if person.year_died && year > person.year_died + 2
            soft_validations.add(:base, "The year of description does not fit the years of #{person.last_name}'s life (#{person.year_born}–#{person.year_died})")
          elsif person.year_born && year > person.year_born + 105
            soft_validations.add(:base, "The year of description does not fit the years of #{person.last_name}'s life (#{person.year_born}–#{person.year_died})")
          elsif person.year_born && year < person.year_born + 10
            soft_validations.add(:base, "The year of description does not fit the years of #{person.last_name}'s life (#{person.year_born}–#{person.year_died})")
          end
        end
      end
    end

    def sv_year_is_not_required
      if !self.year_of_publication.nil? && self.source && self.year_of_publication == self.source.year
        soft_validations.add(
          :year_of_publication, 'Year of publication is not required, it is derived from the source',
          success_message: 'Year was deleted',
          failure_message: 'Failed to delete year')
      end
    end

    def sv_fix_year_is_not_required
      self.update_column(:year_of_publication, nil)
      return true
    end

    def sv_author_is_not_required
      if self.verbatim_author && (!self.taxon_name_author_roles.empty? || (self.source && self.verbatim_author == self.source.authority_name))
        soft_validations.add(
          :verbatim_author, 'Verbatim author is not required, it is derived from the source and taxon name author roles',
          success_message: 'Verbatim author was deleted',
          failure_message:  'Failed to delete verbatim author')
      end
    end

    def sv_fix_author_is_not_required
      self.update_column(:verbatim_author, nil)
      return true
    end

    def sv_misspelling_roles_are_not_required
      #DD: do not use .has_misspelling_relationship?
      misspellings = taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AUTHOR_STRING).any?
      if !self.taxon_name_author_roles.empty? && self.source && misspellings
        soft_validations.add(
          :base, 'Taxon name author role is not required for misspellings and misapplications',
          success_message: 'Roles were deleted',
          failure_message:  'Fail to delete roles')
      end
    end

    def sv_fix_misspelling_roles_are_not_required
      self.taxon_name_author_roles.each do |r|
        r.destroy
      end
      return true
    end

    def sv_misspelling_author_is_not_required
      if self.verbatim_author && self.source && (has_misspelling_relationship? || name_is_misapplied?)
        soft_validations.add(
          :verbatim_author, 'Verbatim author is not required for misspellings and misapplications',
          success_message: 'Verbatim author was deleted',
          failure_message:  'Failed to delete verbatim author')
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
          success_message: 'Year was deleted',
          failure_message:  'Failed to delete year')
      end
    end

    def sv_fix_misspelling_year_is_not_required
      self.update_column(:year_of_publication, nil)
      return true
    end

    def sv_missing_otu
      if is_available? && otus.empty? && rank_string != 'NomenclaturalRank'
        soft_validations.add(
          :year_of_publication, 'Missing OTU',
          success_message: 'OTU was created',
          failure_message:  'Failed to create OTU')
      end
    end

    def sv_fix_misspelling_otu
      if is_available? && otus.empty?
        otus.create(taxon_name_id: id)
        return true
      end
      return false
    end

    def sv_presence_of_combination
      if is_genus_or_species_rank? && is_valid? && self.id == self.lowest_rank_coordinated_taxon.id && !cached_original_combination.nil? && cached != cached_original_combination
        unless Combination.where("cached = ? AND cached_valid_taxon_name_id = ?", cached, cached_valid_taxon_name_id).any?
          soft_validations.add(
            :base, "Protonym #{self.cached_html} missing corresponding subsequent combination. Current classification of the taxon is different from original combination. (Fix will create a new combination)",
            success_message: "Combination #{self.cached_html} was successfully create",
            failure_message:  'Failed to create a new combination')
        end
      end
    end

    def sv_fix_presence_of_combination
      begin
        TaxonName.transaction do
          c = Combination.new
          safe_self_and_ancestors.each do |i|
            case i.rank
              when 'genus'
                c.genus = i
              when 'subgenus'
                c.subgenus = i
              when 'species'
                c.species = i
              when 'subspecies'
                c.subspecies = i
            end
          end
          c.save
        end
      rescue
      end
    end
  end
end



