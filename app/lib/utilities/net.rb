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
          ::Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
            resp = http.head(uri.path)
            case resp.code
              # when '200', '302', '303', '308'
              when /^[23]\d\d$/
                responded = true
              when /^[145]\d\d$/
                responded = false
            end
            # resp.each { |k, v| puts "#{k}: #{v}" }
          end
        end
      end
      responded
    end

    # @param [String] text
    # @return [Object] URI site responce to the request
    def self.ask_about(text)
      uri  = URI.parse(text)
      ::Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.head(uri.path)
      end
    end
  end
end
