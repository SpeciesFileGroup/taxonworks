json.root do
  if @parents.length == 0
    json.partial! 'attributes', lead: @lead
  else
    json.partial! 'attributes', lead: @parents[0]
  end
end

json.lead do
  json.partial! 'attributes', lead: @lead
end

json.left do
  json.partial! 'attributes', lead: @left
end

json.right do
  json.partial! 'attributes', lead: @right
end

json.left_future @left_future
json.right_future @right_future

json.parents @parents
