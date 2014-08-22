def strip_housekeeping_attributes(attributes)
  attributes.delete_if { |k, v| %w{project_id created_by_id updated_by_id lft rgt}.include?(k) }
end

