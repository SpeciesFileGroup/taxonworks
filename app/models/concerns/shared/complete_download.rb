# Scaffolding shared by `Complete` download subclasses: one-per-project (or
# one-per-(project, request)) snapshots of an export that can be regenerated
# on demand and served publicly via the API.
#
# Including classes are expected to implement:
#   * `build` (private) — enqueues the background job that produces the file
#   * `sync_expires_with_preferences` (private) — sets `expires` from project preferences
#
# To plug into the unified `/api/v1/downloads/:download_type` endpoint, including
# classes override the class-method hooks below (`complete_download_lookup_params`,
# `complete_download_access_authorized?`, etc.).
module Shared::CompleteDownload
  extend ActiveSupport::Concern

  included do
    attribute :expires, default: -> { 1.month.from_now }
    attribute :is_public, default: -> { 1 }

    before_save :sync_expires_with_preferences
    after_save :build, unless: :ready?
  end

  class_methods do
    def api_buildable?
      true
    end

    # Returns an existing ready download, raising if one exists but isn't
    # ready. Triggers a PupalComplete rebuild when the existing one is past
    # its max age. Returns nil when no existing download is present.
    def process_complete_download_request(project, params = {})
      download = find_existing(project, params)
      return nil if download.nil?

      raise TaxonWorks::Error, 'The existing download is not ready yet' unless download.ready?

      max_age = complete_download_max_age(project, params)
      if max_age && (Time.current - download.created_at).to_f / 1.day > max_age
        unless pupal_class.find_existing(project, params)
          by_id = Current.user_id || complete_download_default_user_id(project, params)
          pupal_class.create!(by: by_id, project: project, **complete_download_lookup_params(params))
        end
      end

      download.increment!(:times_downloaded)
      download
    end

    def create_complete_download(project, params = {})
      by_id = Current.user_id || complete_download_default_user_id(project, params)
      create!(by: by_id, project: project, **complete_download_lookup_params(params))
    end

    def find_existing(project, params = {})
      where(type: name, project_id: project.id).where(complete_download_lookup_params(params)).first
    end

    def pupal_class
      "#{name.deconstantize}::PupalComplete".constantize
    end

    # --- Subclass hooks; defaults are appropriate for a project-scoped, never-public download. ---

    # Extra scoping for find_existing/create (e.g. { request: otu_id.to_s }).
    def complete_download_lookup_params(_params)
      {}
    end

    # Params required in the request (whitelisted for the controller's permit).
    def complete_download_required_params
      []
    end

    # True iff the project + caller may receive this complete download.
    def complete_download_access_authorized?(_project, _params)
      false
    end

    def complete_download_max_age(_project, _params)
      nil
    end

    def complete_download_default_user_id(_project, _params)
      nil
    end
  end
end
