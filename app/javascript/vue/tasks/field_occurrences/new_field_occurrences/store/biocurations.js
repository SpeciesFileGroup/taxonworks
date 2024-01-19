import { BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'
import { ControlledVocabularyTerm, Tag } from '@/routes/endpoints'
import { defineStore } from 'pinia'

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

export default defineStore('biocurations', {
  state: () => ({
    biocurationGroups: []
  }),

  actions: {
    async loadBiocurationGroups() {
      this.biocurationGroups = await getBiocurationGroupsWithClasses()
    }
  }
})
