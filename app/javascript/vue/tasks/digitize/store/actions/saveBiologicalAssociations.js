import { BiologicalAssociation } from 'routes/endpoints'

export default ({ commit, state: { biologicalAssociations, collection_object } }) =>
  new Promise((resolve, reject) => {
    const promises = []

    biologicalAssociations.forEach((item, index) => {
      if (!item.id) {
        const biological_association = {
          ...item,
          subject_global_id: collection_object.global_id
        }

        BiologicalAssociation.create({ biological_association }).then(response => {
          biologicalAssociations[index] = response.body
        })
      }
    })

    Promise.allSettled(promises).then(responses => {
      resolve(responses)
    })
  })
