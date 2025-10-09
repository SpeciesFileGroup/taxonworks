import { computed } from 'vue'

export function useCSVOptions({ layout, list, transforms, formatters }) {
  const csvFields = computed(() => {
    if (!layout.value) return {}

    const properties = {
      ...layout.value.properties
    }

    for (const key in properties) {
      if (!Array.isArray(properties[key])) {
        if (properties[key].show) {
          const [item] = list.value

          if (item) {
            properties[key] = Object.keys(item[key])
          } else {
            properties[key] = []
          }
        } else {
          delete properties[key]
        }
      }
    }

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

    return {
      fields,
      formatters,
      transforms
    }
  })

  return csvFields
}
