json.array!(@collecting_events) do |collecting_event|
  json.partial! '/collecting_events/api/v1/attributes', collecting_event: collecting_event
end
