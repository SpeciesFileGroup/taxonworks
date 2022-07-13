json.extract! loan, :id, :lender_address, :date_requested, :request_method, :date_sent, :date_received, :date_return_expected, :is_gift, :recipient_address, :recipient_email, :recipient_phone, :recipient_country, :supervisor_email, :supervisor_phone, :date_closed, :created_by_id, :updated_by_id, :project_id, :recipient_honorific, :created_at, :updated_at
json.object_tag loan_tag(loan)
json.url loan_url(loan, format: :json)
json.global_id loan.to_global_id.to_s


if loan.roles.any?
  json.loan_recipient_roles do
    json.array! loan.loan_recipient_roles.each do |role|
      json.extract! role, :id, :position
      json.person do
        json.partial! '/people/base_attributes', person: role.person
      end
    end
  end

  json.loan_supervisor_roles do
    json.array! loan.loan_supervisor_roles.each do |role|
      json.extract! role, :id, :position
      json.person do
        json.partial! '/people/base_attributes', person: role.person
      end
    end
  end
end 

