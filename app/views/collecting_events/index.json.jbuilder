json.array!(@collecting_events) do |collecting_event|
  json.partial! '/collecting_events/attributes', collecting_event:
end
