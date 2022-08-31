module Source::Bibtex::SoftValidationExtensions
  module Klass
    VALIDATIONS = {
      sv_has_some_type_of_year: {
        set: :recommended_fields,
        name: 'Missing year',
        description: 'There is no year nor is there a stated year associated with this source'
      },

      sv_contains_a_writer: {
        set: :recommended_fields,
        name: 'Missing author',
        description: 'There is neither author, nor editor associated with this source'
      },

      sv_duplicate_title: {
        set: :duplicate_title,
        name: 'Duplicate title',
        description: 'Another source with this title exists, it may be duplicate'
      },

      sv_missing_roles: {
        set: :missing_roles,
        name: 'Missing roles',
        description: 'Author roles are not selected'
      },

      sv_has_authors: {
        set: :missing_fields,
        name: 'Missing BibTeX required field author',
        description: 'Valid BibTeX for this type requires author'
      },

      sv_has_title: {
        set: :missing_fields,
        name: 'Missing BibTeX required field title',
        description: 'Valid BibTeX for this type requires title'
      },

      sv_is_article_missing_journal: {
        set: :missing_fields,
        name: 'Missing BibTeX required field journal/Serial',
        description: 'Valid BibTeX for this type requires journal field or Serial selected'
      },

      sv_has_year: {
        set: :missing_fields,
        name: 'Missing BibTeX required field year',
        description: 'Valid BibTeX for this type requires year'
      },

      sv_has_publisher: {
        set: :missing_fields,
        name: 'Missing BibTeX required field publisher',
        description: 'Valid BibTeX for this type requires publisher'
      },

      sv_has_booktitle: {
        set: :missing_fields,
        name: 'Missing BibTeX required field booktitle',
        description: 'Valid BibTeX for this type requires booktitle'
      },

      sv_has_chapter_or_pages: {
        set: :missing_fields,
        name: 'Missing BibTeX required field booktitle',
        description: 'Valid BibTeX for this type requires chapter and/or pages'
      },

      sv_has_school: {
        set: :missing_fields,
        name: 'Missing BibTeX required field school',
        description: 'Valid BibTeX for this type requires school'
      },

      sv_has_institution: {
        set: :missing_fields,
        name: 'Missing BibTeX required field institution',
        description: 'Valid BibTeX for this type requires school'
      },

      sv_has_note: {
        set: :missing_fields,
        name: 'Missing BibTeX required field note',
        description: 'Valid BibTeX for this type requires note'
      },

      sv_electronic_only: {
        set: :electronic_only,
        name: 'Electronic only publication',
        description: 'Validate if the article is published in electronic only journal'
      }
    }

    VALIDATIONS.each_key do |k|
      ::Source::Bibtex.soft_validate(k, VALIDATIONS[k])
    end
  end

  module Instance

    def sv_match_fields?(field)
      Source::Bibtex::BIBTEX_REQUIRED_FIELDS[bibtex_type.to_sym]&.include?(field)
    end

    def sv_has_note
      if bibtex_type == 'unpublished' && note.blank? && !notes.any?
        soft_validations.add(:note, 'Valid BibTeX requires a note with an unpublished source.')
      end
    end

    def sv_has_institution
      if bibtex_type == 'techreport'
        if institution.blank?
          soft_validations.add(:institution, 'Valid BibTeX requires an institution with a tech report.')
        end
      end
    end

    def sv_has_school
      if sv_match_fields?(:school)
        if school.blank?
          soft_validations.add(:school, 'Valid BibTeX requires a school associated with any thesis.')
        end
      end
    end

    def sv_has_chapter_or_pages
      if bibtex_type == 'inbook' && chapter.blank? && pages.blank?
        soft_validations.add(:bibtex_type, 'Valid BibTeX requires either a chapter or pages with sources of type inbook.')
      end
    end

    def sv_has_booktitle
      if sv_match_fields?(:booktitle)
        if booktitle.blank?
          soft_validations.add(:booktitle, 'Valid BibTeX requires a book title to be associated with this source.')
        end
      end
    end

    def sv_has_publisher
      if sv_match_fields?(:publisher)
        if publisher.blank?
          soft_validations.add(:publisher, 'Valid BibTeX requires a publisher to be associated with this source.')
        end
      end
    end

    # neither author nor editor
    def sv_contains_a_writer
      if ['book', 'inbook'].include?(bibtex_type)
        if !has_writer?
          soft_validations.add(:base, 'There is neither author, nor editor associated with this source.')
        end
      end
    end

    def sv_has_authors
      if sv_match_fields?(:author)
        if !(has_authors?)
          soft_validations.add(:author, 'Valid BibTeX requires an author for this type of source.')
        end
      end
    end

    def sv_has_title
      if sv_match_fields?(:title)
        if title.blank?
          soft_validations.add(:author, 'Valid BibTeX requires a title for this type of source.')
        end
      end
    end

    def sv_has_year
      if sv_match_fields?(:year)
        if year.blank?
          soft_validations.add(:year, 'Valid BibTeX requires a year with this type of source.')
        elsif year < 1700
          soft_validations.add(:year, 'This year is prior to the 1700s.')
        end
      end
    end

    def sv_is_article_missing_journal
      if bibtex_type == 'article'
        if journal.nil? && serial_id.nil?
          soft_validations.add(:bibtex_type, 'This article is missing a journal name.')
        elsif serial_id.nil?
          soft_validations.add(:serial_id, 'This article is missing a serial.')
        end
      end
    end

    def sv_electronic_only
      soft_validations.add(:serial_id, 'This article is from the serial which publishes in electronic only format') if self&.serial&.is_electronic_only
    end

    def sv_duplicate_title
      if !title.blank?
        q = Source::Bibtex.where(title: title).where.not(id: id).limit(1).load
        if q.any?
          soft_validations.add(:title, "Other sources (#{q.count}: #{q.pluck(:id).join(',')}) with this title exists, it may be duplicate")
        end
      end
    end

    def sv_has_some_type_of_year
      if !has_some_year?
        soft_validations.add(:base, 'There is no year nor is there a stated year associated with this source.')
      end
    end

    def sv_missing_roles
      soft_validations.add(:base, 'Author roles are not selected.') if author_roles.empty?
    end
  end
end
