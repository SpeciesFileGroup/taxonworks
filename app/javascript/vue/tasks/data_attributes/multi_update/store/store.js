import { defineStore } from 'pinia'
import { QUERY_PARAMETER } from '../../field_synchronize/constants'
import {
  makeDataAttribute,
  makeDataAttributePayload,
  makeObject
} from '../adapters'
import { makePredicate } from '../adapters/makePredicate'
import { DataAttribute } from '@/routes/endpoints'
import { removeFromArray } from '@/helpers'

export default defineStore('store', {
  state: () => ({
    objects: [],
    predicates: [],
    dataAttributes: [],

    isLoading: false,
    isSaving: false,
    save: {
      total: 0,
      current: 0
    },
    settings: {
      append: false
    }
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
      },

    hasUnsaved: (state) => state.dataAttributes.some((item) => item.isUnsaved),

    objectHasUnsaved:
      (state) =>
      ({ objectId, objectType }) =>
        !!state.dataAttributes.find(
          (item) =>
            item.objectId === objectId &&
            item.objectType === objectType &&
            item.isUnsaved
        )
  },

  actions: {
    addPredicate(item) {
      this.predicates.push(makePredicate(item))
    },

    pasteValue({ text, objectId, predicateId }) {
      const lines = text.split('\n')
      const pIndex = this.predicates.findIndex(
        (item) => item.id === predicateId
      )
      let position = this.objects.findIndex((item) => item.id === objectId)

      while (lines.length && position < this.objects.length) {
        const obj = this.objects[position]
        const line = lines.shift()
        const cells = line.split('\t')
        let currentPredicateIndex = pIndex

        while (cells.length && currentPredicateIndex < this.predicates.length) {
          const predicate = this.predicates[currentPredicateIndex]
          const value = cells.shift()
          const trimmedValue = value.trim()

          if (trimmedValue.length) {
            const dataAttributes = this.dataAttributes.filter(
              (da) =>
                da.objectId === obj.id &&
                da.objectType === obj.type &&
                da.predicateId === predicate.id
            )

            if (dataAttributes.length === 1) {
              const [dataAttribute] = dataAttributes

              if (dataAttribute.value !== trimmedValue) {
                if (this.settings.append) {
                  dataAttribute.value += value
                } else {
                  dataAttribute.value = value
                }

                dataAttribute.isUnsaved = true
              }
            }
          }

          currentPredicateIndex++
        }

        position++
      }
    },

    async saveDataAttributes() {
      const dataAttributes = this.dataAttributes.filter(
        (item) => item.isUnsaved
      )

      this.save.total = dataAttributes.length
      this.save.current = 0
      this.isSaving = true

      while (dataAttributes.length) {
        const items = dataAttributes.splice(0, 5)

        const requests = items.map((item) => {
          if (item.value) {
            const request = item.id
              ? DataAttribute.update(item.id, makeDataAttributePayload(item))
              : DataAttribute.create(makeDataAttributePayload(item))

            request
              .then(({ body }) => {
                Object.assign(item, {
                  id: body.id,
                  isUnsaved: false
                })
              })
              .catch(() => {})

            return request
          } else {
            if (item.id) {
              const request = DataAttribute.destroy(item.id)
                .then(() => {
                  Object.assign(item, { id: null, isUnsaved: false })
                })
                .catch(() => {})

              return request
            }
          }
        })

        await Promise.all(requests)

        this.save.current += 5
      }

      this.isSaving = false
      TW.workbench.alert.create('Data attributes were successfully saved.')
    },

    clearColumn(predicate) {
      const dataAttributes = this.dataAttributes.filter(
        (da) => da.predicateId === predicate.id
      )

      dataAttributes.forEach((item) => {
        if (item.value) {
          item.value = ''
          item.isUnsaved = !!item.id
        }
      })
    },

    removePredicate(p) {
      this.predicates = this.predicates.filter(({ id }) => id !== p.id)
      this.dataAttributes = this.dataAttributes.filter(
        ({ predicateId }) => predicateId !== p.id
      )
    },

    reloadDataAttributes(predicateId) {
      this.dataAttributes = this.dataAttributes.filter(
        (da) => da.predicateId !== predicateId
      )
      this.loadDataAttributes(predicateId)
    },

    saveDataAttributesFor({ objectType, objectId }) {
      const dataAttributes = this.dataAttributes.filter(
        (item) =>
          item.objectType === objectType &&
          item.objectId === objectId &&
          item.isUnsaved
      )

      this.save.total = dataAttributes.length
      this.save.current = 0
      this.isSaving = true

      const requests = dataAttributes.map((item) => {
        if (item.value) {
          const request = item.id
            ? DataAttribute.update(item.id, makeDataAttributePayload(item))
            : DataAttribute.create(makeDataAttributePayload(item))

          request
            .then(({ body }) => {
              Object.assign(item, {
                id: body.id,
                isUnsaved: false
              })
            })
            .catch(() => {})

          return request
        } else {
          if (item.id) {
            const request = DataAttribute.destroy(item.id)
              .then(() => {
                const duplicates = this.dataAttributes.filter(
                  (da) =>
                    da.objectType === objectType &&
                    da.objectId === objectId &&
                    da.predicateId === item.predicateId &&
                    da.id !== item.id
                )

                if (duplicates.length) {
                  removeFromArray(this.dataAttributes, item)
                } else {
                  Object.assign(item, { id: null, isUnsaved: false })
                }
              })
              .catch(() => {})

            return request
          }
        }

        this.save.current++
      })

      Promise.all(requests).finally(() => {
        this.isSaving = false
        TW.workbench.alert.create('Data attributes were successfully saved.')
      })

      return requests
    },

    makeTextTableByColumns({ predicateIds, attributes }) {
      const lines = []

      this.objects.forEach((item) => {
        const line = []

        line.push(...attributes.map((attr) => item[attr]))

        this.predicates.forEach((p) => {
          if (predicateIds.includes(p.id)) {
            const dataAttributes = this.getDataAttributesByObject({
              objectId: item.id,
              objectType: item.type,
              predicateId: p.id
            })

            line.push(dataAttributes.map((item) => item.value).join('; '))
          }
        })

        lines.push(line.join('\t'))
      })

      return lines.join('\n')
    },

    loadObjects({ queryParam, queryValue }) {
      const { service } = QUERY_PARAMETER[queryParam]

      this.isLoading = true

      service
        .filter({ ...queryValue, per: 5000 })
        .then(({ body }) => {
          this.objects = body.map(makeObject)
        })
        .finally(() => {
          this.isLoading = false
        })
    },

    async loadDataAttributes(predicateId) {
      const ids = this.objects.map((item) => item.id)
      const objectType = [...new Set(this.objects.map((item) => item.type))]

      const request = DataAttribute.filter({
        controlled_vocabulary_term_id: predicateId,
        attribute_subject_id: ids,
        attribute_subject_type: objectType,
        per: 5000
      })

      this.isLoading = true

      request
        .then(({ body }) => {
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
        .finally(() => {
          this.isLoading = false
        })

      return request
    }
  }
})
