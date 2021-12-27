const findRole = (roles, id) => roles.find(role => !role?._destroy && role.person_id === id)

function getFullName (person) {
  let separator = ''
  if (!!person.last_name && !!person.first_name) {
    separator = ', '
  }
  return (person.last_name + separator + (person.first_name || ''))
}

export {
  findRole,
  getFullName
}
