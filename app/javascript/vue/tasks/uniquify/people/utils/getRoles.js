export default ({ roles }) =>
  [...new Set(roles?.map(r => r.role_object_type))].join(', ') || '?'
