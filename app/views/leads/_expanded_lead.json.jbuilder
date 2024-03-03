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

if extend_response_with('future_otus')
  json.left_future do
    json.partial! 'future_with_otus', future: @left_future
  end
  json.right_future do
    json.partial! 'future_with_otus', future: @right_future
  end
else
  json.left_future @left_future
  json.right_future @right_future
end

json.parents @parents
