module Vendor::SimpleMapprHelper

  # @return CSV
  def simple_mappr_data(params)
    # TODO: Add support for FieldOccurrence, or by Otu Filter

    if params[:collection_object_query]
      a = ::Queries::DwcOccurrence::Filter.new(collection_object_query: params[:collection_object_query]).all.select(:id, :scientificName, :occurrenceID, :decimalLatitude, :decimalLongitude)

      return nil if a.size > 10_000

      d = {}

      a.find_each do |i|
        k = i.scientificName || "[Occurrence id: #{i.occurrenceID}]"
        d[k] ||= []
        d[k].push [i.decimalLatitude, i.decimalLongitude].compact.join(',').presence
      end

      h = d.keys.dup
      z =  CSV::Row.new(h,h,true)

      x = d.values
      max_points_count = x.max {|a, b| a.length <=> b.length}.length
      y = x.shift

      # The array zip here is based (in part) on the length of y, so make sure y
      # is as long as the longest d.values array.
      y.fill(nil, y.length...max_points_count)
      t = y.zip(*x)

      tbl = CSV::Table.new([z], headers: true ) # , col_sep: "\t", encoding: Encoding::UTF_8)

      t.each do |row|
        tbl << CSV::Row.new(h, row, true)
      end

      tbl
    end
  end

end
