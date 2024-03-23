import { BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'
import {
  ControlledVocabularyTerm,
  Tag,
  BiocurationClassification
} from '@/routes/endpoints'
import { defineStore } from 'pinia'
import { addToArray } from '@/helpers'

async function getBiocurationGroupsWithClasses() {
  const { body: list } = await ControlledVocabularyTerm.where({
    type: [BIOCURATION_GROUP, BIOCURATION_CLASS]
  })
  const groups = list.filter(({ type }) => type === BIOCURATION_GROUP)
  const types = list.filter(({ type }) => type === BIOCURATION_CLASS)
  const { body } = await Tag.where({
    keyword_id: groups.map((item) => item.id)
  })

  body.forEach((item) => {
    const group = groups.find((group) => item.keyword_id === group.id)

    if (group) {
      const items = types.filter((type) => type.id === item.tag_object_id)

      group.list = group.list ? [...group.list, ...items] : items
    }
  })

  return groups
}

function makeBiocurationObject(item) {
  return {
    id: item.id,
    uuid: crypto.randomUUID(),
    biocurationClassId: item.biocuration_class_id
  }
}

function makeBiocurationPayload({ biocurationClassId, objectId, objectType }) {
  return {
    biocuration_classification: {
      biocuration_class_id: biocurationClassId,
      biocuration_classification_object_id: objectId,
      biocuration_classification_object_type: objectType
    }
  }
}

export default defineStore('biocurations', {
  state: () => ({
    biocurationGroups: [],
    list: []
  }),

  getters: {
    unsavedBiocurations(state) {
      return state.list.filter((item) => !item.id || item._destroy)
    },

    hasUnsaved(state) {
      return state.list.some((item) => !item.id || item._destroy)
    }
  },

  actions: {
    async add(biocuration) {
      addToArray(
        this.list,
        makeBiocurationObject({ biocuration_class_id: biocuration.id }),
        { property: 'uuid' }
      )
    },

    resetIds() {
      this.list.forEach((item) => {
        item.id = null
      })
    },

    remove(biocurationClass) {
      const index = this.list.findIndex(
        ({ biocurationClassId }) => biocurationClassId === biocurationClass.id
      )
      const biocuration = this.list[index]

      if (biocuration.id) {
        biocuration._destroy = true
      } else {
        this.list.splice(index, 1)
      }
    },

    async loadBiocurationGroups() {
      this.biocurationGroups = await getBiocurationGroupsWithClasses()
    },

    async load({ objectId, objectType }) {
      BiocurationClassification.where({
        biocuration_classification_object_id: objectId,
        biocuration_classification_object_type: objectType
      }).then(({ body }) => {
        this.list = body.map((item) => makeBiocurationObject(item))
      })
    },

    save({ objectId, objectType }) {
      const createList = this.unsavedBiocurations.filter((item) => !item.id)
      const destroyList = this.unsavedBiocurations.filter(
        (item) => item._destroy
      )

      const requests = createList.map((item) =>
        BiocurationClassification.create(
          makeBiocurationPayload({
            objectId,
            objectType,
            biocurationClassId: item.biocurationClassId
          })
        )
      )

      destroyList.forEach((item) => BiocurationClassification.destroy(item.id))

      return Promise.all(requests).then((responses) => {
        const created = this.list.filter((item) => item.id && !item._destroy)

        this.list = [
          ...created,
          ...responses.map((r) => makeBiocurationObject(r.body))
        ]
      })
    }
  }
})
