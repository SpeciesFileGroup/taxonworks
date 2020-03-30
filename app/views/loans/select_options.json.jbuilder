@loans.each_key do |group|
  json.set!(group) do
    json.array! @loans[group] do |l|
      json.partial! '/loans/attributes', loan: l 
    end
  end
end

