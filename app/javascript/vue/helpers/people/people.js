const findRole = (roles, id) => roles.find(role => !role?._destroy && role.person_id === id)

export {
  findRole
}
