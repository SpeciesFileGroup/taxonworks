import { ref } from 'vue'
import { Tag } from 'routes/endpoints'
import { CONTROLLED_VOCABULARY_TERM } from 'constants/index.js'
import { removeFromArray } from 'helpers/arrays'

export default function useBiocurationGroup (groupId) {
  const biologicalGroupClasses = ref([])

  Tag.where({ keyword_id: groupId }).then(({ body }) => {
    biologicalGroupClasses.value = body
  })

  const addBiocuration = id => {
    const tag = {
      tag_object_id: id,
      tag_object_type: CONTROLLED_VOCABULARY_TERM,
      keyword_id: groupId
    }

    Tag.create({ tag }).then(({ body }) => {
      biologicalGroupClasses.value.push(body)
    })
  }

  const removeBiocuration = id => {
    const tag = biologicalGroupClasses.value.find(item => item.tag_object_id === id)

    Tag.destroy(tag.id).then(_ => {
      removeFromArray(biologicalGroupClasses.value, { id: tag.id })
    })
  }

  return {
    biologicalGroupClasses,
    addBiocuration,
    removeBiocuration
  }
}
