import { defineStore } from 'pinia'
import { SoftValidation } from '@/routes/endpoints'

export default defineStore('collectingEventForm:softValidations', {
  state: () => ({
    softValidations: {}
  }),

  actions: {
    async load(globalId) {
      const globalIds = [globalId].flat()

      this.softValidations = {}

      const responses = await Promise.all(
        globalIds.map((id) => SoftValidation.find(id))
      )

      responses.forEach(({ body }) => {
        if (!body.soft_validations.length) return

        const klass = body.instance.klass

        if (!this.softValidations[klass]) {
          this.softValidations[klass] = {
            title: klass,
            list: []
          }
        }

        this.softValidations[klass].list.push(body)
      })
    }
  }
})
