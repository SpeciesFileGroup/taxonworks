# Serves the `Assign taxon name to OTU` task: a page of OTUs that have no taxon_name_id, each
# with its ranked TaxonName match candidates.
#
# Claude (Anthropic) provided > 50% of the code for this class.
class Tasks::Otus::AssignTaxonNameController < ApplicationController
  include TaskControllerConfiguration

  after_action -> { set_pagination_headers(:otus) }, only: [:data], if: :json_request?

  # Ranked candidates offered per row.
  CANDIDATE_COUNT = 5

  # OTUs matched per request, and the maximum page size.
  MAX_PER = 500

  def index
  end

  # GET /tasks/otus/assign_taxon_name/data.json
  def data
    @otus = otu_scope.order(:name).page(params[:page]).per(per)

    # The string each row is matched on: what the curator refined client-side when present,
    # otherwise the OTU name as-is.
    overrides = params[:match_strings] || {}
    match_strings = @otus.collect { |o| overrides[o.id.to_s].presence || o.name }

    matches = ::Match::Otu::TaxonName.new(
      names: match_strings,
      project_id: sessions_current_project_id,
      levenshtein_distance: params[:levenshtein_distance] || 0,
      taxon_name_id: params[:taxon_name_id],
      taxon_name_query: params[:taxon_name_query].presence,
      candidates: CANDIDATE_COUNT,
      match_original_combination: true,
      use_author_year: params[:use_author_year] == 'true',
      trigram_prefilter: true
    ).call

    @rows = @otus.each_with_index.collect do |otu, i|
      { otu:, match_string: match_strings[i], match: matches[i] }
    end
  end

  private

  # @return [Integer]
  def per
    (params[:per].presence || MAX_PER).to_i.clamp(1, MAX_PER)
  end

  # OTUs without a taxon name, optionally narrowed by a handed over OTU query.
  #
  # `taxon_name: false` is applied whatever the incoming query says — an OTU that already has a
  # taxon name is not this task's work.
  # @return [ActiveRecord::Relation]
  def otu_scope
    ::Queries::Otu::Filter.new(
      otu_query_params.merge(taxon_name: false, project_id: sessions_current_project_id)
    ).all
  end

  # Handed to Queries::Otu::Filter unpermitted on purpose — the filter permits against its own
  # PARAMS list.
  # @return [ActionController::Parameters]
  def otu_query_params
    params[:otu_query].presence || ActionController::Parameters.new
  end
end
