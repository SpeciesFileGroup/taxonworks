require 'ruby-graphviz'
require 'matrix'
require 'fileutils'
require 'rainbow'
require 'amazing_print'

namespace :tw do
  namespace :docs do
    namespace :api do

      task param_report: [:environment] do

        # Pre load all the filter subclasses so we can 
        # ask for descendants
        Dir.glob(Rails.root.to_s + '/lib/queries/**/filter.rb').each do |f|
          require_relative Rails.root + f
        end

        puts Rainbow('* - array allowed').gold
        puts Rainbow('annotator param').gray
        puts

        filters = ::Queries::Query::Filter.descendants 
        filters.each do |f|
          puts Rainbow(f.name).blue.bold

          p = f::PARAMS.deep_dup
          array_allowed = []
          if p.last.kind_of?(Hash)
            k = p.pop
            array_allowed = k.keys
          end

          p.each do |i|
            print i 
            if array_allowed.include?(i) 
              print Rainbow('*').gold
            end
            print "\n" 
          end

          # Crude replication of the same loop to get annotator params.
          f.included_annotator_facets.each do |af|

            puts Rainbow('- ' + af.name.split('::').last).blue

            p = af.params
            array_allowed = []
            if p.last.kind_of?(Hash)
              k = p.pop
              array_allowed = k.keys
            end

            p.each do |i|
              print Rainbow(i).gray
              if array_allowed.include?(i) 
                print Rainbow('*').gold
              end
              print "\n" 
            end
          end

          puts
        end
      end
      
    end
  end
end
