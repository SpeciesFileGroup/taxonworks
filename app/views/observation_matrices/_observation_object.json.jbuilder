c = observation_object.class.base_class.name.underscore
json.partial! "#{c.pluralize}/attributes", **{ c.to_sym => observation_object }
