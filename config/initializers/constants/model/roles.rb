
Rails.application.reloader.to_prepare do

  roles = {}
  Role.descendants.each do |k|
    roles[k.name] = k.human_name if k.respond_to?(:human_name)
  end 

  ROLES = roles

end

