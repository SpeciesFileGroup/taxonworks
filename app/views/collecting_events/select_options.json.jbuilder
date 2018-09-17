@collecting_events.each_key do |group|
  json.set!(group) do
    json.array! @collecting_events[group] do |n|
      json.partial! '/collecting_events/attributes', collecting_event: n
    end
  end
end
