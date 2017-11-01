json.extract! loan, :id, :date_requested, :request_method, :date_sent, :date_received, :date_return_expected, :recipient_address, :recipient_email, :recipient_phone, :recipient_country, :supervisor_email, :supervisor_phone, :date_closed, :created_by_id, :updated_by_id, :project_id, :recipient_honorarium, :created_at, :updated_at
json.object_tag loan_tag(loan)
json.url loan_url(loan, format: :json)
json.global_id loan.to_global_id.to_s
