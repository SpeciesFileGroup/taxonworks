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

    def self.finder
      ::Gnfinder::Client.new
    end

    def self.result(text, verification: true, tokens: 3, language: nil, detect_language: true, sources: [ ], project_id: [])
      opts = {
        verification:,
        words_around: tokens,
        sources:
      }
      opts[:language] = 'detect' if detect_language
      opts[:language] = language unless language.nil?

      text = massage_text(text)

      ::Vendor::Gnfinder::Result.new(finder.find_names(text, opts), project_id)
    end

    def self.massage_text(text)
      # TODO: add a flag to the report somewhere
      if !text.valid_encoding?
        text = text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end

      text.gsub!(/sp\.nov/, 'sp. nov') # Ensure there is a space b/w
      text.gsub!(/sp\.nov\./, 'sp. nov. ') # Ensure there is space after
      text.gsub!(/sp\.nov\./, ' sp. nov.') # Ensure there is space before

      text
    end

  end

end

