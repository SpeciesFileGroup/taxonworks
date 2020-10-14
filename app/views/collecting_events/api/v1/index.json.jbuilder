json.array!(@collecting_events) do |collecting_event|
  json.partial! 'attributes', collecting_event: collecting_event
end
