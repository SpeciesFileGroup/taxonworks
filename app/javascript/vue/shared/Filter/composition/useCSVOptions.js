import { computed } from 'vue'
import { sortArray } from '@/helpers'

export function useCSVOptions({ layout, list }) {
  const predicateNames = computed(() => {
    return sortArray([
      ...new Set(
        list.value?.map((item) => Object.keys(item.data_attributes)).flat()
      )
    ])
  })

  const csvFields = computed(() => {
    const { includes, properties } = layout.value

    function getObjectPaths(obj, prefix = '') {
      return Object.entries(obj).flatMap(([key, value]) =>
        typeof value === 'object' && value !== null
          ? getObjectPaths(value, `${prefix}${key}.`)
          : {
              label: `${prefix}${value}`.replaceAll('.', '_'),
              value: `${prefix}${value}`
            }
      )
    }

    const fields = getObjectPaths(properties)

    if (includes.data_attributes) {
      fields.push(
        ...predicateNames.value.map((p) => ({
          label: `data_attributes_${p}`,
          value: `data_attributes.${p}`
        }))
      )
    }

    return { fields }
  })

  return csvFields
}
