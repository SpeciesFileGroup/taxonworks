type = @annotation.class.name.underscore
json.partial! "#{type.pluralize}/attributes", type.to_sym => @annotation
