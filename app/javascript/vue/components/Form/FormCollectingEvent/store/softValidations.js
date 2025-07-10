import { defineStore } from 'pinia'
import { SoftValidation } from '@/routes/endpoints'

export default defineStore('collectingEventForm:softValidations', {
  state: () => ({
    softValidations: {}
  }),

  actions: {
    load(globalId) {
      const globalIds = [globalId].flat()

      const promises = globalIds.map((globalId) =>
        SoftValidation.find(globalId).then(({ body }) => {
          this.softValidations = {}

          if (body.soft_validations.length) {
            this.softValidations[body.instance.klass] = {
              list: [body],
              title: body.instance.klass
            }
          }
        })
      )

      return Promise.all(promises)
    }
  }
})
