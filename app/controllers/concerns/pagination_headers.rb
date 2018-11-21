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
  end
end
