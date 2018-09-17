@repositories.each_key do |group|
  json.set!(group) do
    json.array! @repositories[group] do |n|
      json.partial! '/repositories/attributes', repository: n
    end
  end
end
