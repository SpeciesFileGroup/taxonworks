json.lead do
  json.partial! 'attributes', lead: @lead
end

json.future @future
