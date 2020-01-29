# Injects Pagination headers.
#
# To implement these headers add a line to your controller:
#
#  class OtusController < ApplicationController
#     `after_action -> { set_pagination_headers(:otus) }, on: [:index], if: :json_request?`
#  end
#
# We can also use the method directly within a view, but for uniformity we'll do it like this.
#
# For future reference see also https://www.w3.org/TR/ldp-paging/.
module PaginationHeaders
  extend ActiveSupport::Concern

  include RequestType

  included do
    protected

    def set_pagination_headers(name)
      scope = instance_variable_get("@#{name}")
      scope.tap do |d|
        # See how can we fit what is described in the url below to avoid double-querying
        # https://stackoverflow.com/questions/156114/best-way-to-get-result-count-before-limit-was-applied/8242764#8242764
        response.set_header('Pagination-Total', d.total_count.to_s )
        response.set_header('Pagination-Total-Pages', d.total_pages.to_s )
        response.set_header('Pagination-Page', d.current_page.to_s )
        response.set_header('Pagination-Per-Page', d.limit_value.to_s )
        response.set_header('Pagination-Next-Page', d.next_page.to_s )
        response.set_header('Pagination-Previous-Page', d.prev_page.to_s )

        # TODO: Add 'Link' following LD - https://www.w3.org/wiki/LinkHeader
      end
    end

    helper_method :set_pagination_headers

    def set_object_navigation_headers(name)
      o = instance_variable_get("@#{name}")

      n = o.next&.id&.to_s
      p = o.previous&.id&.to_s
      ni = o.next_by_identifier&.id&.to_s
      np = o.previous_by_identifier&.id&.to_s
      response.set_header('Navigation-Next', n) if n
      response.set_header('Navigation-Previous', p) if p
      response.set_header('Navigation-Next-By-Identifier', ni) if ni
      response.set_header('Navigation-Previous-By-Identifier', np) if np
    end

    helper_method :set_object_navigation_headers

  end
end
