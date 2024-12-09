import { defineStore } from 'pinia'
import { QUERY_PARAMETER } from '../../field_synchronize/constants'
import { makeObject } from '../adapters'

export default defineStore('store', {
  state: () => ({
    objects: [],
    predicates: []
  }),

  actions: {
    loadObjects({ queryParam, queryValue }) {
      const { service } = QUERY_PARAMETER[queryParam]

      service.where(queryValue).then(({ body }) => {
        this.objects = body.map(makeObject)
      })
    }
  }
})
