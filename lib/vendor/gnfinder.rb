module Vendor

  # TODO
  #  Verify mode! do this first
  #     user has manually entered all names - should see matches on playground 
  #     highlight where not
  #
  #  Curate/add mode 
  #   * talk to Hernán about getting `gnfinder` in shell or GRPC
  #   * flesh out the Name model
  #   * get José to add `name=` params to new combination
  #   * get José to add `name=` params to new taxon name   
  #   * bonus - include `source_id=` to auto-cite result
  #
  #   * Show missmatched classification for match names
  #   * Show page numbers
  module Gnfinder 

    # TODO: verification preferred/not

    # C - with verification
    # @param tokens [Integer, nil]
    # @param verification  [Boolean]
    # @return [Hash]
    def self.to_json(text, verification = true, tokens = nil)
      return {} if text.nil? || text.empty?
      c = "gnfinder find"
      c = c + ' -c' if verification
      c = c + ' -t #{tokens}' if tokens && tokens > 0

      t = Open3.popen2(c) {|i,o,t|
        i.puts text 
        i.close
        o.read
      }

      JSON.parse(t, symbolize_names: true)
    end

  end

end

require_relative 'gnfinder/name'
require_relative 'gnfinder/result'
