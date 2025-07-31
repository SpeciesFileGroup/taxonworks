export default ({ role_counts }) =>
  [...new Set(Object.values(role_counts || {}).map((v) => Object.keys(v)).flat())].join(', ') || '?'
