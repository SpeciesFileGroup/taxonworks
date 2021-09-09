require 'fileutils'

namespace :tw do
  namespace :development do
    namespace :linting do

      desc 'check some nomenclatural constants for consistency'
      task ensure_constants_reference_models: [:environment] do |t| 
        Rails.application.eager_load!
        i = 0
        TAXON_NAME_RELATIONSHIP_NAMES.each do |r|
          if r.safe_constantize.nil?
            i += 1
            puts Rainbow(r).red
          end
        end 
        puts "All good" if i == 0
      end 

      desc 'check some nomenclatural data for consistency'
      task ensure_taxon_name_relationship_type_reference_models: [:environment] do |t| 
        Rails.application.eager_load!
        i = 0
        TaxonNameRelationship.select(:type).distinct.pluck(:type).each do |r|
          if r.safe_constantize.nil?
            i += 1
            puts Rainbow(r).red
          end
        end 
        puts "All good" if i == 0
      end 

      desc 'list annotated models'
      task  list_annotated_models: [:environment] do |t|
        Rails.application.eager_load!

        annotations = ::ANNOTATION_TYPES.inject({}) {|hsh, a| hsh.merge!(a => [] )}

        ApplicationRecord.subclasses.sort{|a,b| a.name <=> b.name}.each do |d|
          ::ANNOTATION_TYPES.each do |a|
            m = "has_#{a}?"
            annotations[a].push d.name if d.respond_to?(m) && d.send(m)
          end
        end

        annotations.each do |k, v|
          puts Rainbow(k).bold.blue
          v.each do |c|
            puts "   #{c}"
            if k == :citations
              puts Rainbow('    missing _attributes').red if !File.exists?(Rails.root.to_s + "/app/views/#{k}/_attributes.json.jbuilder")
            end
          end
        end

      end

      # rake tw:development:linting:list_models_with_soft_validations
      desc 'list models with soft validations'
      task  list_models_with_soft_validations: [:environment] do |t|
        Rails.application.eager_load!

        annotations = []
        ApplicationRecord.subclasses.sort{|a,b| a.name <=> b.name}.each do |d|
          annotations.push d.name if d.respond_to?(:soft_validators)  && d.soft_validators.any? # TODO: not tested && !d.soft_validation_methods[d.name].empty?
        end

        annotations.each do |a|
          puts "* [ ] #{a}"
        end
      end

    end
  end
end
