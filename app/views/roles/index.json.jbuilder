json.array!(@roles) do |role|
  json.partial! 'attributes', role: role
end
