json.array! @result do |r|
  json.index r[:index]

  json.parsed do
    json.extract! r[:input], :surnames, :year, :year_suffix, :title, :journal,
      :volume, :first_page, :doi
  end

  json.candidates r[:candidates] do |c|
    json.source do
      json.extract! c[:source], :id, :cached_author_string, :year,
        :year_suffix, :volume, :pages
      # Rendered with v-html; source_tag sanitizes to <i> only.
      json.object_label source_tag(c[:source])
      json.global_id c[:source].to_global_id.to_s
    end

    json.extract! c, :in_project, :year_difference, :year_suffix_match,
      :first_author_exact, :first_author_distance, :author_distances,
      :source_author_count, :title_similarity, :journal_similarity,
      :volume_match, :first_page_match, :doi_match
  end
end
