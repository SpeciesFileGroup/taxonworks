# Each distinct Source's label is rendered once; Sources repeat across rows.
labels = {}

json.array! @result do |r|
  json.index r[:index]

  json.parsed do
    json.extract! r[:input], :surnames, :first_author_initials, :year,
      :year_suffix, :volume, :first_page, :doi
  end

  json.candidates r[:candidates] do |c|
    json.source do
      json.id c[:source].id
      json.object_label(labels[c[:source].id] ||= source_tag(c[:source]))
    end

    json.extract! c, :in_project, :year_difference, :year_suffix_match,
      :first_author_exact, :first_author_distance, :matched_author_counts,
      :first_author_initials_match, :source_first_author_initials,
      :source_author_count,
      :title_similarity, :journal_similarity, :volume_match,
      :first_page_match, :title_required, :doi_match, :corroborated
  end
end
