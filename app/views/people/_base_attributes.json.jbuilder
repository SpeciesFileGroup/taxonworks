json.extract! person, :id, :type, :last_name, :first_name, :suffix, :prefix,
  :cached, :year_born, :year_died, :year_active_start, :year_active_end,
  :created_by_id, :updated_by_id, :created_at, :updated_at

json.global_id person.to_global_id.to_s