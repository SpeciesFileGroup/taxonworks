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

    SERVER = 'finder-rpc.globalnames.org'
    PORT = '80'

    def self.finder
      ::Gnfinder::Client.new(SERVER, PORT)
    end

    def self.result(text, verification: true, tokens: 3, language: nil, detect_language: true, sources: [ ], project_id: [])
      ::Vendor::Gnfinder::Result.new(
        finder.find_names(
          text,
          verification: verification,
          tokens_around: tokens,
          sources: sources,
          language: language,
          detect_language: true
        ), project_id)
    end
  end

end

