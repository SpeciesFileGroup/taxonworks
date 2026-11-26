json.status @evaluation.status

if (match = @evaluation.match)
  json.match do
    json.id match[:source].id
    json.cached match[:source].cached
  end
else
  json.match nil
end

json.parsed do
  json.extract! @evaluation.input, :surnames, :first_author_initials, :year,
    :year_suffix, :volume, :first_page, :doi
end

json.candidates(
  @evaluation.listed.first(SourcesController::API_MATCH_CANDIDATES_LIMIT)
) do |c|
  json.id c[:source].id
  json.cached c[:source].cached
  json.agrees c[:agrees]
  json.disagrees c[:disagrees]
  json.corroborated c[:corroborated]
  json.in_project c[:in_project] if @in_project
end
