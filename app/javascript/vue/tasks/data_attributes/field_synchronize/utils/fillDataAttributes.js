import { makeDataAttribute } from '../factory'

export function fillDataAttributes(obj, predicateList) {
  predicateList.forEach(({ id }) => {
    if (!obj[id]) {
      obj[id] = [makeDataAttribute({ predicateId: id })]
    }
  })

  return obj
}
