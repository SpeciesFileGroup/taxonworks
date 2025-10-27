#!/usr/bin/env ruby

require 'thor'
require 'net/http'
require 'json'
require 'uri'
require 'cgi'
require 'bok_choy'

# BHL Meta Service - Reconciles data between TaxonWorks, GlobalNames BHLNames, and BHL
#
# IMPORTANT: Four distinct page/identifier concepts are used throughout:
#
# 1. BHL Item IDs (bhl_item_id)
#    - The ID of the collective physical/digital thing being referenced
#    - Found in URLs as: /item/10277
#    - Example: 10277 from https://www.biodiversitylibrary.org/item/10277
#
# 2. BHL Relative Page (bhl_relative_page)
#    - The BHL system's internal page identifier (relative to the item)
#    - Found in URLs as: /page/12345 or #page/597
#    - Does NOT always correspond 1-1 with physical page numbers
#    - Example: 597 from https://www.biodiversitylibrary.org/item/10277#page/597
#
# 3. BHL Physical Page Numbers (bhl_physical_page_number)
#    - The actual page number(s) printed on the physical page
#    - Cannot be extracted from URLs; must be retrieved via BHL API metadata
#    - May include: roman numerals (i, ii, iii), letters, or complex ranges
#    - Example: "343" or "xlii" or "12a-12b"
#
# 4. TaxonWorks Page Numbers (taxonworks_pages)
#    - The 'pages' attribute in TaxonWorks Source model
#    - Curator-entered citation page numbers
#    - Should ideally match BHL physical page numbers, but may vary
#    - Example: "343-344" in a citation
#
class BHLMetaService < Thor

  desc "reconcile", "Reconcile a BHL page URL with a taxon name across multiple sources"
  option :name, required: true, aliases: '-n', desc: 'Taxon name to search for'
  option :url, required: true, aliases: '-u', desc: 'BHL page URL'
  option :limit, type: :numeric, default: 5, aliases: '-l', desc: 'Number of ranked sources to return'
  option :extended, type: :boolean, default: false, aliases: '-e', desc: 'Show extended suggestions and metadata diff'

  def reconcile
    puts "\n=== BHL Meta Service ==="
    puts "Name: #{options[:name]}"
    puts "URL: #{options[:url]}"

    # Extract BHL identifiers from URL
    bhl_ids = extract_bhl_identifiers(options[:url])
    puts "\nExtracted BHL Identifiers:"
    puts " bhl_ids: #{bhl_ids}"
    puts "  Item ID: #{bhl_ids[:item_id] || 'not found'}"
    puts "  Relative Page: #{bhl_ids[:relative_page] || 'not found'}"

    puts "\nQuerying multiple APIs...\n\n"

    # Use relative page for queries (backward compatibility)
    page_id = bhl_ids[:relative_page]
    item_id = bhl_ids[:item_id]

    # Query all APIs
    bhl_data = query_bhl_names(options[:name], page_id, item_id)
    tw_data = query_taxonworks(options[:name])

    # Collect IDs from multiple sources
    ids = collect_taxon_ids(options[:name], tw_data, bhl_data)
    display_taxon_ids(ids)

    # Rank and display sources
    ranked_sources = rank_sources(options[:name], page_id, bhl_data, tw_data)
    display_ranked_sources(ranked_sources, options[:limit])

    # Only show extended information if --extended flag is set
    if options[:extended]
      # Suggest metadata diff
      if page_id && bhl_data && !bhl_data.empty?
        suggest_metadata_diff(page_id, bhl_data, tw_data)
      end

      # Suggest API endpoints if no direct path exists
      suggest_api_endpoints(options[:name], page_id)
    end

  rescue StandardError => e
    puts "\nError: #{e.message}"
    puts e.backtrace.join("\n") if ENV['DEBUG']
  end

  private

  # Extract BHL identifiers from various BHL URL formats
  # Returns a hash with:
  #   - item_id: BHL item ID (from /item/123)
  #   - relative_page: BHL relative page number (from /page/456 or #page/789)
  #   - physical_page_number: Page number printed on the page (not extractable from URL)
  def extract_bhl_identifiers(url)
    return { item_id: nil, relative_page: nil } unless url

    result = { item_id: nil, relative_page: nil }

    # Extract item ID from /item/12345
    if url =~ /\/item\/(\d+)/
      result[:item_id] = $1
    end

    # Extract relative page from /page/12345 (direct page URL)
    if url =~ /\/page\/(\d+)/
      result[:relative_page] = $1
    # Or from #page/12345 (item URL with page fragment)
    elsif url =~ /#page\/(\d+)/
      result[:relative_page] = $1
    end

    result
  end

  # Backward compatibility: extract BHL page ID from URL
  # This is now deprecated in favor of extract_bhl_identifiers
  def extract_bhl_page_id(url)
    ids = extract_bhl_identifiers(url)
    ids[:relative_page]
  end

  # Query GlobalNames BHLNames API using bok_choy gem
  def query_bhl_names(name, page_id = nil, item_id = nil)
    puts "→ Querying GlobalNames BHLNames API (via bok_choy)..."

    return [] unless defined?(BokChoy)

    results = []

    # Search by name
    if name
      #puts "  [DEBUG] BokChoy.name_refs(name: '#{name}')"
      name_results = BokChoy.name_refs(name:)
      if name_results && name_results['names']
        results.concat(name_results['names'])
      end
    end

    # If we have a page ID, also query by page
    if page_id
      #puts "  [DEBUG] BokChoy.references('#{page_id}')"
      page_results = BokChoy.references(page_id)
      if page_results && page_results['names']
        results.concat(page_results['names'])
      elsif page_results && page_results['pageId']
        results << page_results
      end
    end

    puts "  Found #{results.size} results from BHLNames"
    results

  rescue => e
    puts "  Error querying BHLNames: #{e.message}"
    puts "  #{e.backtrace.first}" if ENV['DEBUG']
    []
  end

  # Query TaxonWorks API across all projects
  def query_taxonworks(name)
    puts "→ Querying TaxonWorks API across all projects..."

    # Get list of all projects with open API access
    projects = get_taxonworks_projects
    puts "  Found #{projects.size} projects with open API access"

    all_results = []

    # Query each project
    projects.each do |project|
      project_name = project['name']
      token = project['project_token']

      url = "https://sfg.taxonworks.org/api/v1/taxon_names?name=#{CGI.escape(name)}&project_token=#{token}"
      response = make_request(url)

      next unless response

      data = JSON.parse(response.body)
      results = data.is_a?(Array) ? data : []

      if results.any?
        # Add project context to each result
        results.each do |result|
          result['_project_name'] = project_name
          result['_project_token'] = token

          # Fetch origin citations for this taxon name
          if result['id']
            citations = fetch_origin_citations(result['id'], token)
            result['_origin_citations'] = citations
          end
        end
        all_results.concat(results)
      end
    end

    puts "  Found #{all_results.size} total results from TaxonWorks"
    all_results

  rescue => e
    puts "  Error querying TaxonWorks: #{e.message}"
    puts "  #{e.backtrace.first}" if ENV['DEBUG']
    []
  end

  # Fetch origin citations for a taxon name ID
  def fetch_origin_citations(taxon_name_id, project_token)
    url = "https://sfg.taxonworks.org/api/v1/citations?project_token=#{project_token}&citation_object_id=#{taxon_name_id}&citation_object_type=TaxonName&extend[]=source"
    response = make_request(url)

    return [] unless response

    data = JSON.parse(response.body)
    citations = data.is_a?(Array) ? data : []

    puts "    Found #{citations.size} origin citation(s) for taxon_name_id #{taxon_name_id}" if citations.any?
    citations

  rescue => e
    puts "    Error fetching citations for taxon_name_id #{taxon_name_id}: #{e.message}"
    []
  end

  # Get list of all TaxonWorks projects with open API access
  def get_taxonworks_projects
    url = "https://sfg.taxonworks.org/api/v1"
    response = make_request(url)

    return [] unless response

    data = JSON.parse(response.body)['open_projects']
    data.is_a?(Array) ? data : []

  rescue => e
    puts "  Error fetching TaxonWorks projects: #{e.message}"
    []
  end

  # Collect taxon IDs from multiple sources
  def collect_taxon_ids(name, tw_data, bhl_data)
    ids = {
      taxonworks: [],
      global_names: [],
      bhl: [],
      col: []
    }

    # TaxonWorks IDs
    if tw_data && tw_data.is_a?(Array)
      tw_data.each do |item|
        ids[:taxonworks] << {
          id: item['id'],
          name: item['name'] || item['cached'],
          rank: item['rank'],
          project: item['_project_name'],
          citations: item['_origin_citations']
        } if item['id']
      end
    end

    # GlobalNames IDs from BHL
    if bhl_data && bhl_data.is_a?(Array)
      bhl_data.each do |item|
        if item['gnUuid']
          ids[:global_names] << {
            uuid: item['gnUuid'],
            name: item['name']
          }
        end

        if item['pageId']
          ids[:bhl] << {
            page_id: item['pageId'],  # Relative page
            item_id: item['itemId'],
            titleName: item['titleName'],
            mainTaxon: item['mainTaxon']
          }
        end
      end
    end

    # Could query COL API here for additional IDs
    # For now, suggesting this as an endpoint (see suggest_api_endpoints)
#puts "ids: #{ids}"
    ids
  end

  # Display collected taxon IDs
  def display_taxon_ids(ids)
    puts "\n=== Taxon Name IDs Across Sources ==="

    if ids[:taxonworks].any?
      puts "\nTaxonWorks IDs:"
      ids[:taxonworks].each do |item|
        project_info = item[:project] ? " (Project: #{item[:project]})" : ""
        puts "  - ID: #{item[:id]}, Name: #{item[:name]}, Rank: #{item[:rank]}#{project_info}"

        # Display origin citations if available
        if item[:citations] && item[:citations].any?
          puts "    Origin Citations:"
          item[:citations].each do |citation|
            # Use citation_source_body if available, otherwise fallback
            source_display = citation['citation_source_body'] || citation&.dig('source', 'cached') || 'Unknown title'
            pages = citation['pages']
            puts "      • #{source_display}"
          end
        end
      end
    end

    if ids[:global_names].any?
      puts "\nGlobal Names UUIDs:"
      ids[:global_names].uniq { |i| i[:uuid] }.each do |item|
        puts "  - UUID: #{item[:uuid]}, Name: #{item[:name]}"
      end
    end

    if ids[:bhl].any?
      puts "\nBHL IDs:"
      ids[:bhl].uniq { |i| i[:page_id] }.each do |item|
        puts "  - Relative Page: #{item[:page_id]}, Item ID: #{item[:item_id]}, Name: #{item[:titleName]}, mainTaxon: #{item[:mainTaxon]}"
      end
    end

    if ids[:col].any?
      puts "\nCatalogue of Life IDs:"
      ids[:col].each do |item|
        puts "  - #{item}"
      end
    end

    puts "\nNote: Additional IDs could be retrieved via COL API integration"
  end

  # Rank sources based on confidence score
  def rank_sources(name, page_id, bhl_data, tw_data)
    sources = []

    # Process BHL data
    #puts "bhl_data: #{bhl_data}"
    if bhl_data && bhl_data.is_a?(Array)
      bhl_data.each do |item|
        next unless item['titleName']

        score = calculate_confidence_score(name, page_id, item)

        source = {
          type: 'BHL',
          title: item['titleName'] || 'Unknown Title',
          page: item['pageNumber'] || item['pageId'],
          name_found: item['name'],
          item_id: item['itemId'],
          page_id: item['pageId'],
          year: item['year'],
          score: score,
          metadata: item
        }

        sources << source
      end
    end

    # Process TaxonWorks data - match against sources
    if tw_data && tw_data.is_a?(Array)
      tw_data.each do |item|
        # Get origin citation from the fetched citations array
        origin_citation = item['_origin_citations']&.first

        score = calculate_tw_confidence_score(name, item)
#puts "origin citation: #{origin_citation}"
        source = {
          type: 'TaxonWorks',
          title: origin_citation&.dig('source', 'cached') || '(No citation provided)',
          page: origin_citation&.dig('pages'),
          name_found: item['name'] || item['cached'],
          tw_id: item['id'],
          tw_project: item['_project_name'],
          year: item['year_of_publication'],
          score: score,
          metadata: item,
          citation: origin_citation
        }

        sources << source
      end
    end

    # Sort by score (highest first)
    sources.sort_by { |s| -s[:score] }
  end

  # Calculate confidence score for BHL results
  def calculate_confidence_score(name, page_id, item)
    score = 0.0

    # Exact name match
    if item['name']&.downcase == name.downcase
      score += 50.0
    elsif item['name']&.downcase&.include?(name.downcase)
      score += 30.0
    elsif name.downcase.include?(item['name']&.downcase || '')
      score += 20.0
    end

    # Page ID match
    if page_id && item['pageId'].to_s == page_id.to_s
      score += 40.0
    end

    # Has metadata
    score += 5.0 if item['title']
    score += 5.0 if item['year']
    score += 5.0 if item['itemId']

    score
  end

  # Calculate confidence score for TaxonWorks results
  def calculate_tw_confidence_score(name, item)
    score = 0.0

    item_name = item['name'] || item['cached']

    # Exact name match
    if item_name&.downcase == name.downcase
      score += 50.0
    elsif item_name&.downcase&.include?(name.downcase)
      score += 30.0
    end

    # Has citation information
    score += 10.0 if item['_origin_citations']&.any?
    score += 5.0 if item['year_of_publication']
    score += 5.0 if item['author']

    score
  end

  # Display ranked sources
  def display_ranked_sources(sources, limit)
    puts "\n=== Top #{limit} Ranked Sources ==="

    sources.first(limit).each_with_index do |source, index|
      puts "\n#{index + 1}. [Score: #{source[:score].round(1)}] #{source[:type]}"
      puts "   Title: #{source[:title]}"
      puts "   Page: #{source[:page]}" if source[:page]
      puts "   Year: #{source[:year]}" if source[:year]
      puts "   Name Found: #{source[:name_found]}"
      puts "   Page ID: #{source[:page_id]}" if source[:page_id]
      puts "   Item ID: #{source[:item_id]}" if source[:item_id]
      puts "   TaxonWorks ID: #{source[:tw_id]}" if source[:tw_id]
      puts "   TaxonWorks Project: #{source[:tw_project]}" if source[:tw_project]
    end

    if sources.empty?
      puts "\nNo sources found. See API endpoint suggestions below."
    end
  end

  # Suggest metadata diff between BHL and TaxonWorks
  def suggest_metadata_diff(page_id, bhl_data, tw_data)
    puts "\n=== Metadata Diff Suggestions ==="

    # Find the best BHL match
    bhl_match = bhl_data.find { |item| item['pageId'].to_s == page_id.to_s }
    bhl_match ||= bhl_data.first

    return unless bhl_match

    puts "\nBHL Page Metadata:"
    puts "  Title: #{bhl_match['title']}"
    puts "  Page Number: #{bhl_match['pageNumber']}"
    puts "  Year: #{bhl_match['year']}"
    puts "  Item ID: #{bhl_match['itemId']}"
    puts "  Volume: #{bhl_match['volume']}" if bhl_match['volume']

    if tw_data && !tw_data.empty?
      tw_match = tw_data.first

      puts "\nTaxonWorks Source Metadata:"
      origin_citation = tw_match['_origin_citations']&.first
      if origin_citation
        puts "  Source: #{origin_citation['source']&.dig('cached')}"
        puts "  Pages: #{origin_citation['pages']}"
        puts "  Year: #{tw_match['year_of_publication']}"
      else
        puts "  No origin citation found in TaxonWorks"
      end

      puts "\nSuggested Actions:"
      puts "  • Verify page number matches between sources"
      puts "  • Check if BHL item #{bhl_match['itemId']} is linked in TaxonWorks"
      puts "  • Consider adding external identifier for BHL page #{page_id}"
    else
      puts "\nNo TaxonWorks data to compare. Consider:"
      puts "  • Creating a new Source in TaxonWorks for this BHL item"
      puts "  • Adding external identifier linking to BHL page #{page_id}"
    end
  end

  # Suggest API endpoints when there's no direct path
  def suggest_api_endpoints(name, page_id)
    puts "\n=== Suggested API Endpoints for Better Integration ==="

    puts "\nTo improve data linking, consider implementing these RESTful endpoints:"

    puts "\n1. TaxonWorks - External Identifiers Endpoint"
    puts "   GET /api/v1/taxon_names/{id}/identifiers"
    puts "   → Return external identifiers (GBIF, COL, BHL, GlobalNames UUIDs)"
    puts "   POST /api/v1/taxon_names/{id}/identifiers"
    puts "   → Add external identifier with namespace and value"

    puts "\n2. TaxonWorks - Source to BHL Link Endpoint"
    puts "   GET /api/v1/sources/{id}/bhl_items"
    puts "   → Return associated BHL item IDs and page ranges"
    puts "   POST /api/v1/sources/{id}/bhl_items"
    puts "   → Link a source to BHL item with page mappings"

    puts "\n3. BHLNames - Enhanced Page Endpoint"
    puts "   GET /api/v1/pages/{page_id}/names"
    puts "   → Current endpoint, but could include name verification status"
    puts "   GET /api/v1/pages/{page_id}/metadata"
    puts "   → Full bibliographic metadata for the page's source"

    puts "\n4. Cross-Reference Endpoint (New Service)"
    puts "   GET /api/v1/reconcile?name={name}&bhl_page={page_id}"
    puts "   → Returns matched records across TaxonWorks, BHL, COL, GBIF"
    puts "   → Includes confidence scores and suggested matches"

    puts "\n5. COL Integration"
    puts "   GET /api/v1/taxon_names/{id}/col_match"
    puts "   → Query COL API and return matching taxa with IDs"
    puts "   → Use colrapi gem: https://github.com/SpeciesFileGroup/colrapi"

    puts "\n6. BHL Page Verification"
    puts "   POST /api/v1/verify_name_on_page"
    puts "   → Payload: {name: '...', bhl_page_id: '...'}"
    puts "   → Returns: {verified: true/false, confidence: 0-100}"
    puts "   → Could use OCR text from BHL to verify name presence"
  end

  # Make HTTP request with basic error handling
  def make_request(url, method: :get, headers: {}, body: nil)
    # Echo URL request to terminal for debugging
    #puts "  [DEBUG] #{method.to_s.upcase} #{url}"

    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.read_timeout = 10

    request = case method
              when :get
                Net::HTTP::Get.new(uri.request_uri)
              when :post
                req = Net::HTTP::Post.new(uri.request_uri)
                req.body = body if body
                req
              end

    headers.each { |k, v| request[k] = v }
    request['Accept'] = 'application/json'

    response = http.request(request)

    # Echo response status for debugging
    #puts "  [DEBUG] Response: HTTP #{response.code} #{response.message}"

    if response.code.to_i >= 400
      puts "  Warning: HTTP #{response.code} for #{url}"
      return nil
    end

    response

  rescue => e
    puts "  Error making request to #{url}: #{e.message}"
    nil
  end
end

# Run the CLI
BHLMetaService.start(ARGV) if __FILE__ == $0
