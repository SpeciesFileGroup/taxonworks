import { makeDataAttribute } from './makeDataAttribute'
import { fillDataAttributes } from '../utils'

export function makeDataAttributeList({ data, predicates }) {
  const obj = {}

  data.forEach(([id, objectId, predicateId, value]) => {
    const dataAttribute = makeDataAttribute({
      id,
      predicateId,
      value,
      objectId
    })
    const dataAttributes = obj[objectId]

    if (dataAttributes) {
      const arr = dataAttributes[predicateId]

      if (arr) {
        arr.push(dataAttribute)
      } else {
        dataAttributes[predicateId] = [dataAttribute]
      }
    } else {
      obj[objectId] = {
        [predicateId]: [dataAttribute]
      }
    }
  })

  for (const key in obj) {
    fillDataAttributes(obj[key], predicates)
  }

  return obj
}
