json.array!(@loans) do |loan|
  json.extract! loan, :id, :date_requested, :request_method, :date_sent, :date_received, :date_return_expected, :recipient_person_id, :recipient_address, :recipient_email, :recipient_phone, :recipient_country, :supervisor_person_id, :supervisor_email, :supervisor_phone, :date_closed, :created_by_id, :updated_by_id, :project_id, :recipient_honorific
  json.url loan_url(loan, format: :json)
end
