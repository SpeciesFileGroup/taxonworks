json.array!(@collecting_events.includes(collector_roles: [:person])) do |collecting_event|
  json.partial! '/collecting_events/attributes', collecting_event: collecting_event
end
