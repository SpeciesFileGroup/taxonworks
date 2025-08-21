module Shared::Api
  extend ActiveSupport::Concern

  def self.api_link(ar, id = nil)
    s = ENV['SERVER_NAME']
    if s.nil?
      s ||= 'http://127.0.0.1:3000'
    else
      s = 'https://' + s
    end

    return s + '/api/v1/' if ar.nil?

    s = s + "/api/v1/#{ar.class.base_class.name.downcase.pluralize}/#{id || ar.id}"
  end
end