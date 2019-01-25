export default function(person, roleType) {
  return {
    first_name: person.first_name,
    last_name: person.last_name,
    person: {
      id: person.id
    },
    person_id: person.id,
    type: roleType
  }
}