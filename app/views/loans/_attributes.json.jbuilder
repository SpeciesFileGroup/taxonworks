json.extract! loan, :id, :lender_address, :date_requested, :request_method, :date_sent, :date_received, :date_return_expected, :is_gift, :recipient_address, :recipient_email, :recipient_phone, :recipient_country, :supervisor_email, :supervisor_phone, :date_closed,  :recipient_honorific, :created_at, :updated_at, :created_by_id, :updated_by_id

json.partial! '/shared/data/all/metadata', object: loan

if extend_response_with('status')
  json.overdue loan.overdue?
  json.total_loan_items loan.loan_items.count
  json.days_overdue loan.days_overdue
  json.days_until_due loan.days_until_due
  json.families loan.families
end

if extend_response_with(:roles) 
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

end
