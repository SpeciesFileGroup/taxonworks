json.partial! 'attributes', container: @container

if @container.contained?
  json.contained_by do
    json.partial! 'attributes', container: @container.container
  end
end
