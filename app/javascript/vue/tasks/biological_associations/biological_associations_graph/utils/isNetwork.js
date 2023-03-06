export function isNetwork(biologicalAssociations) {
  const subjects = biologicalAssociations.map((edge) => edge.subject)
  const objects = biologicalAssociations.map((edge) => edge.object)

  const uniqueObjects = [...new Set(objects)]
  const uniqueSubjects = [...new Set(subjects)]

  return (
    subjects.some((nodeId) => objects.includes(nodeId)) ||
    uniqueSubjects.length < subjects.length ||
    uniqueObjects.length < objects.length
  )
}
