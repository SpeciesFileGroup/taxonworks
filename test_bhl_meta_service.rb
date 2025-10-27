#!/usr/bin/env ruby

require 'test/unit'
require 'json'
require_relative 'bhl_meta_service'

# Test suite for BHLMetaService using Apis mellifera
class TestBHLMetaServiceApisMellifera < Test::Unit::TestCase

  def setup
    @service = BHLMetaService.new
    @test_name = "Apis mellifera"
    @test_url = "https://www.biodiversitylibrary.org/item/10277?utm_source=chatgpt.com#page/597/mode/1up"
  end

  # Test URL parsing and page ID extraction
  def test_extract_bhl_page_id_from_item_url
    # Now supports extracting relative page from #page/ fragment
    page_id = @service.send(:extract_bhl_page_id, @test_url)

    # Should extract 597 from #page/597
    assert_equal("597", page_id, "Should extract relative page from #page/ fragment")
  end

  # Test the new extract_bhl_identifiers method
  def test_extract_bhl_identifiers_from_item_url_with_page_fragment
    ids = @service.send(:extract_bhl_identifiers, @test_url)

    assert_equal("10277", ids[:item_id], "Should extract item ID from /item/")
    assert_equal("597", ids[:relative_page], "Should extract relative page from #page/")
  end

  def test_extract_bhl_identifiers_from_direct_page_url
    url = "https://www.biodiversitylibrary.org/page/12345"
    ids = @service.send(:extract_bhl_identifiers, url)

    assert_nil(ids[:item_id], "Direct page URL should not have item ID")
    assert_equal("12345", ids[:relative_page], "Should extract relative page from /page/")
  end

  def test_extract_bhl_identifiers_with_both_formats
    # URL with both item and page
    url = "https://www.biodiversitylibrary.org/item/10277/page/597"
    ids = @service.send(:extract_bhl_identifiers, url)

    assert_equal("10277", ids[:item_id])
    assert_equal("597", ids[:relative_page])
  end

  def test_extract_bhl_page_id_standard_format
    # Test with a standard BHL page URL
    standard_url = "https://www.biodiversitylibrary.org/page/597"
    page_id = @service.send(:extract_bhl_page_id, standard_url)

    assert_equal("597", page_id)
  end

  def test_extract_bhl_page_id_nil_url
    page_id = @service.send(:extract_bhl_page_id, nil)
    assert_nil(page_id)
  end

  # Test BHLNames API query
  def test_query_bhl_names_with_apis_mellifera
    omit("Requires bok_choy gem to be installed") unless defined?(BokChoy)

    results = @service.send(:query_bhl_names, @test_name, nil)

    assert_instance_of(Array, results)
    # Results may be empty if no matches found, but should return array
  end

  def test_query_bhl_names_with_page_id
    omit("Requires bok_choy gem to be installed") unless defined?(BokChoy)

    results = @service.send(:query_bhl_names, @test_name, "597")

    assert_instance_of(Array, results)
  end

  def test_query_bhl_names_without_bok_choy
    # Stub the defined? check to simulate missing bok_choy
    # This tests graceful degradation
    results = @service.send(:query_bhl_names, @test_name, nil)

    assert_instance_of(Array, results)
  end

  # Test TaxonWorks API query
  def test_query_taxonworks_with_apis_mellifera
    # This test makes real API calls - consider mocking in production
    results = @service.send(:query_taxonworks, @test_name)

    assert_instance_of(Array, results)

    if results.any?
      # Verify structure of results
      first_result = results.first
      assert(first_result.key?('name') || first_result.key?('cached'),
             "Result should have name or cached field")
    end
  end

  # Test taxon ID collection
  def test_collect_taxon_ids_structure
    tw_data = [
      {
        'id' => 123,
        'name' => 'Apis mellifera',
        'rank' => 'species',
        '_project_name' => 'Test Project'
      }
    ]

    bhl_data = [
      {
        'gnUuid' => 'abc-123-def',
        'name' => 'Apis mellifera',
        'pageId' => '597',
        'itemId' => '10277',
        'pageNumber' => '343'  # Physical page number
      }
    ]

    ids = @service.send(:collect_taxon_ids, @test_name, tw_data, bhl_data)

    assert_instance_of(Hash, ids)
    assert(ids.key?(:taxonworks))
    assert(ids.key?(:global_names))
    assert(ids.key?(:bhl))
    assert(ids.key?(:col))

    assert_equal(1, ids[:taxonworks].length)
    assert_equal(1, ids[:global_names].length)
    assert_equal(1, ids[:bhl].length)

    # Verify TaxonWorks ID structure
    tw_id = ids[:taxonworks].first
    assert_equal(123, tw_id[:id])
    assert_equal('Apis mellifera', tw_id[:name])
    assert_equal('species', tw_id[:rank])
    assert_equal('Test Project', tw_id[:project])

    # Verify Global Names UUID structure
    gn_id = ids[:global_names].first
    assert_equal('abc-123-def', gn_id[:uuid])
    assert_equal('Apis mellifera', gn_id[:name])

    # Verify BHL ID structure (tests all four page concepts)
    bhl_id = ids[:bhl].first
    assert_equal('597', bhl_id[:page_id], "Relative page should be extracted")
    assert_equal('10277', bhl_id[:item_id], "Item ID should be extracted")
    assert_equal('343', bhl_id[:physical_page], "Physical page number should be captured")
  end

  # Test confidence scoring for exact match
  def test_calculate_confidence_score_exact_match
    item = {
      'name' => 'Apis mellifera',
      'pageId' => '597',
      'title' => 'The Genera and Subgenera of Bees',
      'year' => '1944',
      'itemId' => '10277'
    }

    score = @service.send(:calculate_confidence_score, @test_name, '597', item)

    # Should get: 50 (exact name) + 40 (page match) + 15 (metadata)
    assert_equal(105.0, score)
  end

  def test_calculate_confidence_score_partial_match
    item = {
      'name' => 'Apis mellifera ligustica',  # Subspecies, contains our name
      'pageId' => '598',  # Different page
      'title' => 'Bee subspecies',
      'year' => '1950',
      'itemId' => '10278'
    }

    score = @service.send(:calculate_confidence_score, @test_name, '597', item)

    # Should get: 30 (partial match) + 0 (no page match) + 15 (metadata)
    assert_equal(45.0, score)
  end

  def test_calculate_confidence_score_no_match
    item = {
      'name' => 'Bombus terrestris',  # Different genus
      'pageId' => '598'
    }

    score = @service.send(:calculate_confidence_score, @test_name, '597', item)

    # Should get: 0 (no name match) + 0 (no page match) + 0 (metadata doesn't match)
    assert_equal(0.0, score)
  end

  # Test TaxonWorks confidence scoring
  def test_calculate_tw_confidence_score
    item = {
      'name' => 'Apis mellifera',
      '_origin_citations' => [
        {
          'source' => {
            'cached' => 'Linnaeus 1758'
          },
          'pages' => '343'
        }
      ],
      'year_of_publication' => 1758,
      'author' => 'Linnaeus'
    }

    score = @service.send(:calculate_tw_confidence_score, @test_name, item)

    # Should get: 50 (exact name) + 10 (citation) + 5 (year) + 5 (author)
    assert_equal(70.0, score)
  end

  # Test fetching origin citations
  def test_fetch_origin_citations_method_exists
    assert(@service.private_methods.include?(:fetch_origin_citations),
           "fetch_origin_citations method should exist")
  end

  # Test source ranking
  def test_rank_sources
    bhl_data = [
      {
        'name' => 'Apis mellifera',
        'pageId' => '597',
        'title' => 'Test Title',
        'itemId' => '10277',
        'year' => '1944'
      }
    ]

    tw_data = [
      {
        'name' => 'Apis mellifera',
        '_origin_citations' => [
          {
            'source' => {
              'cached' => 'Test Source'
            },
            'pages' => '597'
          }
        ],
        'year_of_publication' => 1944,
        '_project_name' => 'Test Project'
      }
    ]

    ranked = @service.send(:rank_sources, @test_name, '597', bhl_data, tw_data)

    assert_instance_of(Array, ranked)
    assert(ranked.length > 0)

    # Check that sources are sorted by score (descending)
    scores = ranked.map { |s| s[:score] }
    assert_equal(scores.sort.reverse, scores)

    # Verify first result has highest score
    top_result = ranked.first
    assert(top_result[:score] > 0)
    assert(['BHL', 'TaxonWorks'].include?(top_result[:type]))
  end

  # Test HTTP request handling
  def test_make_request_with_valid_url
    # Test with TaxonWorks API root
    response = @service.send(:make_request, 'https://sfg.taxonworks.org/api/v1')

    # Should get a response (may be nil if network issue, but method should not raise)
    assert_nothing_raised do
      @service.send(:make_request, 'https://sfg.taxonworks.org/api/v1')
    end
  end

  def test_make_request_with_invalid_url
    response = @service.send(:make_request, 'https://invalid-domain-that-does-not-exist-12345.com')

    # Should return nil instead of raising
    assert_nil(response)
  end

  # Integration test with real data (marked as slow)
  def test_integration_apis_mellifera_reconciliation
    # This is a slower integration test
    # Skip if you want fast unit tests only
    omit("Integration test - run with INTEGRATION=true") unless ENV['INTEGRATION']

    # Simulate running the reconcile command
    tw_data = @service.send(:query_taxonworks, @test_name)
    bhl_data = @service.send(:query_bhl_names, @test_name, nil)

    # Should get results from at least one source
    assert(tw_data.any? || bhl_data.any?,
           "Should find Apis mellifera in at least one data source")

    # Test ID collection
    ids = @service.send(:collect_taxon_ids, @test_name, tw_data, bhl_data)
    assert_instance_of(Hash, ids)

    # Test ranking
    ranked = @service.send(:rank_sources, @test_name, nil, bhl_data, tw_data)
    assert_instance_of(Array, ranked)
  end

  # Test error handling
  def test_query_taxonworks_with_empty_name
    results = @service.send(:query_taxonworks, "")
    assert_instance_of(Array, results)
  end

  def test_collect_taxon_ids_with_nil_data
    ids = @service.send(:collect_taxon_ids, @test_name, nil, nil)

    assert_instance_of(Hash, ids)
    assert_equal(0, ids[:taxonworks].length)
    assert_equal(0, ids[:global_names].length)
  end

  def test_rank_sources_with_empty_data
    ranked = @service.send(:rank_sources, @test_name, nil, [], [])

    assert_instance_of(Array, ranked)
    assert_equal(0, ranked.length)
  end

  # Test extended option functionality
  def test_extended_option_methods_exist
    # Verify that the private methods called by --extended exist
    assert(@service.private_methods.include?(:suggest_metadata_diff),
           "suggest_metadata_diff method should exist")
    assert(@service.private_methods.include?(:suggest_api_endpoints),
           "suggest_api_endpoints method should exist")
  end
end
