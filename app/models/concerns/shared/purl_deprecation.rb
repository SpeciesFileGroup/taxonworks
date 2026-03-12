# frozen_string_literal: true
module Shared::PurlDeprecation
  extend ActiveSupport::Concern

  included do
    include SoftValidation
    soft_validate(
      :sv_purl_not_deprecated,
      set: :purl,
      name: 'Deprecated PURL',
      description: 'Provided URI does not appear to be in use'
    )
  end

  # Override in the including class if the attribute name differs.
  def purl_value
    respond_to?(:uri) ? uri : nil
  end

  # HEAD the PURL, follow a few redirects, and flag common “deprecated” cases.
  def sv_purl_not_deprecated
    url = purl_value
    return if url.blank?

    response, final_url = head_follow(url)

    code = response&.code.to_i
    deprecated = false
    message = nil

    case code
    when 410 # Gone – common for retired PURLs
      deprecated = true
      message = 'responds 410 (Gone)'
    when 301, 302, 303, 307, 308
      # Heuristics: a lot of obo PURLs redirect to replacement/obsolete pages
      if final_url&.match?(/obsolete|deprecated|replaced|superseded/i)
        deprecated = true
        message = "redirects to '#{final_url}' which looks deprecated/obsolete"
      end
    when 404
      deprecated = true
      message = 'responds 404 (Not Found)'
    else
      # Some servers return 200 OK to an “obsolete term” landing page.
      # Do a very lightweight GET only when code is 200 and host looks like OBO.
      if code == 200 && URI(url).host =~ /purl\.obolibrary\.org/i
        if looks_obsolete_landing?(final_url || url)
          deprecated = true
          message = 'lands on a page that looks like an obsolete/deprecated term'
        end
      end
    end

    if deprecated
      soft_validations.add(
        :uri,
        "PURL #{message}.",
      )
    end
  rescue => e
    # Don't hard-fail SV on network hiccups
    soft_validations.add(:uri, "PURL check could not be completed (#{e.class}: #{e.message}).")
  end

  private

  def head_follow(url, limit: 10)
    raise 'too many redirects' if limit <= 0

    uri = URI.parse(url)
    path = uri.request_uri.presence || '/'
    response = ::Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.head(path) }

    if response.is_a?(Net::HTTPRedirection) && (location = response['location']).present?
      return head_follow(location, limit: limit - 1)
    end
    [response, url]
  end

  # Very light heuristic to avoid full HTML parsing:
  # only for obo PURLs, fetch and scan a small chunk for “obsolete/deprecated”.
  def looks_obsolete_landing?(url)
    uri = URI.parse(url)
    return false unless uri.host =~ /obolibrary|purl\.obolibrary\.org/i

    req_path = uri.request_uri.presence || '/'
    body = ''
    ::Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request_get(req_path, { 'Range' => 'bytes=0-4096' }) do |r|
        body = r.body.to_s
      end
    end
    body.match?(/obsolete|deprecated|superseded/i)
  rescue
    false
  end
end
