# Methods for enumerating models, tables, columns etc. 
# !! If you think that a method belongs here chances are it already exists in a Rails extension.
#
# Note the use of Module.nesting (http://urbanautomaton.com/blog/2013/08/27/rails-autoloading-hell/)
#
module ApplicationEnumeration

  # return [Array]
  #   a list symbols that represent of populated, non "cached", non "_id", non reserved attributes
  def self.alternate_value_attributes(object)
    if object.class::ALTERNATE_VALUES_FOR.blank?
      raise("#{object.class} attempted to annotate a class without ALTERNATE_VALUES_FOR -  please inform the programmers")
    else
      object.attributes.select{|k,v| !v.blank? && object.class::ALTERNATE_VALUES_FOR.include?(k.to_sym)}.keys.map(&:to_sym)
    end

  end
  def self.annotatable_attributes(object)
    object.attributes.select{|k,v| !v.blank? && !(k =~ /.*_id\z|cached_*.*/)}.keys.map(&:to_sym) - RESERVED_ATTRIBUTES
  end

  # !! See the built in self.descendants for actual inheritance tracking, this is path based.
  # Return all models in the /app/models/#{klass.name} (not necessarily inheriting) as an Array of Classes.
  # Used in Ranks.
  def self.all_submodels(klass)
    Dir.glob(Rails.root + "app/models/#{klass.name.underscore}/**/*.rb").collect{|a| self.model_from_file_name(a) }
  end

  # Return the Class represented by a path included filename from /app/models.
  # e.g. given 'app/models/specimen.rb' the Specimen class is returned
  def self.model_from_file_name(file_name)
    file_name.split(/app\/models\//).last[0..-4].split(/\\/).collect{|b| b.camelize}.join("::").safe_constantize
  end

end
