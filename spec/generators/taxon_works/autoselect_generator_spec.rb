require 'rails_helper'
require 'rails/generators'
require 'rails/generators/testing/behavior'
require 'rails/generators/testing/assertions'
require 'generators/taxon_works/autoselect/autoselect_generator'

# Generator specs use a temporary destination directory to avoid modifying the real codebase.
# They only verify that files are created with the correct names and paths.
RSpec.describe TaxonWorks::AutoselectGenerator, type: :generator do
  include Rails::Generators::Testing::Behavior
  include Rails::Generators::Testing::Assertions
  include FileUtils

  tests TaxonWorks::AutoselectGenerator
  destination File.expand_path('../../tmp/generators', __dir__)

  # Helper to build a Pathname inside the destination dir
  def dest_file(*path_parts)
    Pathname.new(destination_root).join(*path_parts)
  end

  describe 'generating taxon_name with --fast and catalog_of_life level' do
    before do
      prepare_destination
      run_generator %w[taxon_name catalog_of_life --fast --no-example]
    end

    specify 'creates lib/autoselect/taxon_name/autoselect.rb' do
      expect(dest_file('lib/autoselect/taxon_name/autoselect.rb')).to exist
    end

    specify 'creates lib/autoselect/taxon_name/operators.rb' do
      expect(dest_file('lib/autoselect/taxon_name/operators.rb')).to exist
    end

    specify 'creates fast level' do
      expect(dest_file('lib/autoselect/taxon_name/levels/fast.rb')).to exist
    end

    specify 'creates catalog_of_life custom level stub' do
      expect(dest_file('lib/autoselect/taxon_name/levels/catalog_of_life.rb')).to exist
    end

    specify 'autoselect.rb references Fast, Smart, CatalogOfLife levels' do
      content = dest_file('lib/autoselect/taxon_name/autoselect.rb').read
      expect(content).to include('Levels::Fast')
      expect(content).to include('Levels::Smart')
      expect(content).to include('Levels::CatalogOfLife')
    end

    specify 'autoselect.rb has correct module nesting' do
      content = dest_file('lib/autoselect/taxon_name/autoselect.rb').read
      expect(content).to include('module Autoselect')
      expect(content).to include('module TaxonName')
      expect(content).to include('class Autoselect < ::Autoselect')
    end

    specify 'autoselect.rb has resource_path for taxon_names' do
      content = dest_file('lib/autoselect/taxon_name/autoselect.rb').read
      expect(content).to include('/taxon_names/autoselect')
    end

    specify 'autoselect.rb has response_values with taxon_name_id' do
      content = dest_file('lib/autoselect/taxon_name/autoselect.rb').read
      expect(content).to include('taxon_name_id')
    end

    specify 'fast level has correct class name and key' do
      content = dest_file('lib/autoselect/taxon_name/levels/fast.rb').read
      expect(content).to include('class Fast < ::Autoselect::Level')
      expect(content).to include(':fast')
    end

    specify 'catalog_of_life custom level has correct class name and key' do
      content = dest_file('lib/autoselect/taxon_name/levels/catalog_of_life.rb').read
      expect(content).to include('class CatalogOfLife < ::Autoselect::Level')
      expect(content).to include(':catalog_of_life')
    end
  end

  describe 'generating otu with catalog_of_life (no --fast)' do
    before do
      prepare_destination
      run_generator %w[otu catalog_of_life --no-example]
    end

    specify 'creates autoselect.rb' do
      expect(dest_file('lib/autoselect/otu/autoselect.rb')).to exist
    end

    specify 'does NOT create a fast level' do
      expect(dest_file('lib/autoselect/otu/levels/fast.rb')).not_to exist
    end

    specify 'autoselect.rb does NOT reference Fast level' do
      content = dest_file('lib/autoselect/otu/autoselect.rb').read
      expect(content).not_to include('Levels::Fast')
    end

    specify 'autoselect.rb references Smart and CatalogOfLife levels' do
      content = dest_file('lib/autoselect/otu/autoselect.rb').read
      expect(content).to include('Levels::Smart')
      expect(content).to include('Levels::CatalogOfLife')
    end

    specify 'autoselect.rb has resource_path for otus' do
      content = dest_file('lib/autoselect/otu/autoselect.rb').read
      expect(content).to include('/otus/autoselect')
    end

    specify 'autoselect.rb has response_values with otu_id' do
      content = dest_file('lib/autoselect/otu/autoselect.rb').read
      expect(content).to include('otu_id')
    end
  end

end
