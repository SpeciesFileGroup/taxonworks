import { addToArray, removeFromArray } from '@/helpers'

export function useAnnotationHandlers(annotationLists) {

  function handleRadialCreate({ item }) {
    if (annotationLists[item.base_class]) {
      addToArray(annotationLists[item.base_class].value, item)
    }
  }

  function handleRadialDelete({ item }) {
    if (annotationLists[item.base_class]) {
      removeFromArray(annotationLists[item.base_class].value, item)
    }
  }

  function handleRadialUpdate({ item }) {
    if (annotationLists[item.base_class]) {
      addToArray(annotationLists[item.base_class].value, item)
    }
  }

  return { handleRadialCreate, handleRadialDelete, handleRadialUpdate }
}