function CreatePerson (person, roleType) {
  return {
    first_name: person.first_name,
    last_name: person.last_name,
    person_id: person.id,
    type: roleType
  }
}

export {
  CreatePerson
}