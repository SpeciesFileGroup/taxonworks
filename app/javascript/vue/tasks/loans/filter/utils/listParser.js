import { ProjectMember } from '@/routes/endpoints'

export async function listParser(list) {
  const { body } = await ProjectMember.all()
  const members = body.reduce((acc, curr) => {
    acc[curr.user.id] = curr.user.name
    return acc
  }, {})

  return list.map((item) => ({
    ...item,
    identifiers: item.identifiers?.map((i) => i.cached).join('; '),
    updated_by: members[item.updated_by_id],
    created_by: members[item.created_by_id]
  }))
}
