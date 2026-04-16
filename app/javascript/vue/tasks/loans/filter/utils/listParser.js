import { ProjectMember } from '@/routes/endpoints'

export async function listParser(list) {
  const { body } = await ProjectMember.all()
  const members = body.reduce((acc, curr) => {
    acc[curr.user.id] = curr.user.name
    return acc
  }, {})

  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    identifiers: item.identifiers?.map((i) => i.cached).join('; '),
    lender_address: item.lender_address,
    date_requested: item.date_requested,
    request_method: item.request_method,
    date_sent: item.date_sent,
    date_received: item.date_received,
    date_return_expected: item.date_return_expected,
    is_gift: item.is_gift ? 'Yes' : 'No',
    recipient_name: item.loan_recipient_roles
      .map((r) => r.person.cached)
      .join('; '),
    recipient_address: item.recipient_address,
    recipient_email: item.recipient_email,
    recipient_phone: item.recipient_phone,
    recipient_country: item.recipient_country,
    supervisor_name: item.loan_supervisor_roles
      .map((r) => r.person.cached)
      .join('; '),
    supervisor_email: item.supervisor_email,
    supervisor_phone: item.supervisor_phone,
    date_closed: item.date_closed,
    recipient_honorific: item.recipient_honorific,
    updated_by: members[item.updated_by_id],
    created_by: members[item.created_by_id]
  }))
}
