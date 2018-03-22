# General purpose Net related methods
module Utilities
  # Special general routines for Net-specific itams
  module Net
    # @param [String] text
    # @return [Boolean] true if URI site responds positivly to the request
    def self.resolves?(text)
      responded = false
      if text =~ /^http(s)*:\/\/(.+)/ # http:// or  https://
        parsed = true
        uri    = URI.parse(text)
        if uri.host.nil?
          parsed = false
        end
        if parsed
          http = ::Net::HTTP.start(uri.host)
          resp = http.head(uri.path)
          case resp.code
            # when '200', '302', '303', '308'
            when /^[23]\d\d$/
              responded = true
            when /^[145]\d\d$/
              responded = false
          end
          # resp.each { |k, v| puts "#{k}: #{v}" }
          http.finish
        end
      end
      responded
    end

    # @param [String] text
    # @return [Boolean] true if URI site responds positivly to the request
    def self.ask_about(text)
      uri  = URI.parse(text)
      http = ::Net::HTTP.start(uri.host)
      resp = http.head(uri.path)
      http.finish
      resp
    end
  end
end
