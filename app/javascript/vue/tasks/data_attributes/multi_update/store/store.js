import { defineStore } from 'pinia'
import { QUERY_PARAMETER } from '../../field_synchronize/constants'
import { makeDataAttribute, makeObject } from '../adapters'
import { makePredicate } from '../adapters/makePredicate'
import { DataAttribute } from '@/routes/endpoints'

export default defineStore('store', {
  state: () => ({
    objects: [],
    predicates: [],
    dataAttributes: []
  }),

  getters: {
    getDataAttributesByObject:
      (state) =>
      ({ objectType, objectId, predicateId }) => {
        return state.dataAttributes.filter(
          (da) =>
            da.objectType === objectType &&
            da.objectId === objectId &&
            da.predicateId === predicateId
        )
      }
  },

  actions: {
    addPredicate(item) {
      this.predicates.push(makePredicate(item))
    },

    pasteValue(text, index) {
      const lines = text.split('\n')
    },

    loadObjects({ queryParam, queryValue }) {
      const { service } = QUERY_PARAMETER[queryParam]

      service.where(queryValue).then(({ body }) => {
        this.objects = body.map(makeObject)
      })
    },

    async loadDataAttributes(predicateId) {
      const ids = this.objects.map((item) => item.id)
      const objectType = [...new Set(this.objects.map((item) => item.type))]

      const request = DataAttribute.where({
        controlled_vocabulary_term_id: predicateId,
        attribute_subject_id: ids,
        attribute_subject_type: objectType
      })

      request.then(({ body }) => {
        const items = body.map(makeDataAttribute)

        this.objects.forEach((obj) => {
          const dataAttributes = items.filter(
            (item) => item.objectType === obj.type && item.objectId === obj.id
          )

          if (dataAttributes.length) {
            this.dataAttributes.push(...dataAttributes)
          } else {
            this.dataAttributes.push(
              makeDataAttribute({
                controlled_vocabulary_term_id: predicateId,
                attribute_subject_type: obj.type,
                attribute_subject_id: obj.id
              })
            )
          }
        })
      })

      return request
    }
  }
})
