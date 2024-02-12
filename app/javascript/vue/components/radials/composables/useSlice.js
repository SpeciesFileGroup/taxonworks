import { ref } from 'vue'
import { addToArray, removeFromArray } from '@/helpers'

export function useSlice({ radialEmit }) {
  const list = ref([])

  function remove(item, property = 'id') {
    removeFromArray(list.value, item, property)
    radialEmit.count(list.value.length)
    radialEmit.delete(item)
    radialEmit.change(item)
  }

  function add(item, opts) {
    const length = list.value.length

    addToArray(list.value, item, opts)
    radialEmit.change(item)

    if (list.value.length !== length) {
      radialEmit.add(item)
      radialEmit.count(list.value.length)
    } else {
      radialEmit.update(item)
    }
  }

  return {
    add,
    remove,
    list
  }
}
