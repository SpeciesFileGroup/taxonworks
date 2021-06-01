import { Depiction, TaxonDetermination, CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import validateSqed from '../../helpers/validateSqed'

export default ({ state, commit }) => {
  const { collection_object, tags, repository, taxon_determinations } = state
  const promises = []
  let createdCount = 0
  let alreadyCreated

  function createNewCOForStage () {
    return ((state.objectsForDepictions.length === 0) && (state.sqed.layout && state.sqed.boundary_color))
  }

  state.settings.saving = true
  if (createNewCOForStage()) {
    state.imagesCreated.forEach(item => {
      collection_object.data_attributes_attributes = state.data_attributes.map(item => ({
        controlled_vocabulary_term_id: item.controlled_vocabulary_term_id,
        type: item.type,
        value: item.value
      }))

      collection_object.tags_attributes = tags.map(tag => ({ keyword_id: tag.id }))
      collection_object.repository_id = repository?.id

      promises.push(CollectionObject.create({ collection_object }).then(response => {
        const depiction = {
          depiction_object_id: response.body.id,
          depiction_object_type: 'CollectionObject',
          image_id: item.id,
          caption: state.depiction.caption.length ? state.depiction.caption : undefined,
          sqed_depiction_attributes: (validateSqed(state.sqed) ? state.sqed : undefined)
        }

        taxon_determinations.forEach(taxon_determination => {
          taxon_determination.biological_collection_object_id = response.body.id
          TaxonDetermination.create({ taxon_determination })
        })

        createdCount++
        Depiction.create({ depiction }).then(response => {
          commit(MutationNames.AddDepiction, response.body)
        })
      }))
    })
  }
  else {
    state.objectsForDepictions.forEach(object => {
      state.imagesCreated.forEach(item => {
        const depiction = {
          depiction_object_id: object.id,
          depiction_object_type: object.base_class,
          image_id: item.id,
          caption: state.depiction.caption.length ? state.depiction.caption : undefined,

          sqed_depiction_attributes: (validateSqed(state.sqed) && state.objectsForDepictions.length === 1 && object.base_class === 'CollectionObject') ? state.sqed : undefined
        }

        alreadyCreated = state.depictionsCreated.find(depictionCreated =>
          depictionCreated.depiction_object_id === object.id &&
          depictionCreated.depiction_object_type === object.base_class &&
          depictionCreated.image_id === item.id)

        if (!alreadyCreated) {
          promises.push(Depiction.create({ depiction }).then(response => {
            createdCount++
            commit(MutationNames.AddDepiction, response.body)
          }))
        }
        else {
          depiction.id = alreadyCreated.id
          if (depiction.sqed_depiction_attributes && alreadyCreated?.sqed_depiction?.id) {
            depiction.sqed_depiction_attributes.id = alreadyCreated.sqed_depiction.id
          }
          promises.push(Depiction.update(depiction.id, { depiction }).then(response => {
            commit(MutationNames.AddDepiction, response.body)
          }))
        }
      })
    })
  }

  Promise.all(promises).then(() => {
    state.settings.saving = false
    if (createdCount > 0) {
      TW.workbench.alert.create('Depiction(s) was successfully created.', 'notice')
    }
  })
}