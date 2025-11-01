require 'bok_choy'

module Vendor

  # A middle-layer wrapper between BokChoy and TaxonWorks
  module BokChoy
    def self.items_page_nums(item_id: nil, page_num: nil)
      r = ::BokChoy.items_page_nums(item_id:, page_num:)

      source_from_result(r)
    end

    def self.references(page_id)
      r = ::BokChoy.references(page_id)

      source_from_result(r)
    end

    def self.source_from_result(r)
      return Source.new if r.nil?

      # TODO: do we ever get article authors?
      Source.new(
        year: r.dig('part', 'year') || r.dig('itemYearStart'), # TODO: End as well?
        pages: r.dig('part', 'pages') || r.dig('pageNum'), # TODO: is pageNum an array?? pages is not double-hyphened (it's single)
        journal: r.dig('titleName'), # TODO: won't always be journal
        volume: r.dig('volume'),
        url: r.dig('url'),
        title: r.dig('part', 'name')
      )
    end
  end
end
