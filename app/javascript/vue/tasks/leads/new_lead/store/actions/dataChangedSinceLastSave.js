import editableChildrenFields from '../constants/editableChildrenFields'

export default function() {
  if (
    this.children.length > 0 && (
      originLabelChangedSinceLastSave(this) ||
      childrenChangedSinceLastSaveList(this).length > 0
    )
  ) {
    return true
  }
  return false
}

export function childrenChangedSinceLastSaveList(store = this) {
  return childrenDifferentEditableValues(
    store.last_saved.children, store.children
  )
}

export function originLabelChangedSinceLastSave(store = this) {
  return differentOriginLabels(
    store.last_saved.origin_label,
    store.lead.origin_label
  )
}

function differentOriginLabels(l1, l2) {
  if (!l1 && !l2) { // treat null and '' as the same
    return false
  }
  return l1 != l2
}

function childrenDifferentEditableValues(arr1, arr2) {
  let different = []
  arr1.forEach((c1, i) => {
    const c2 = arr2[i]
    if (differentEditableValues(c1, c2)) {
      different.push(c2)
    }
  })
  return different
}

function differentEditableValues(obj1, obj2) {
  for (const field of editableChildrenFields) {
    if (!obj1[field] && !obj2[field]) { // treat null and '' as the same
      continue
    }
    if (obj1[field] != obj2[field]) {
      return true
    }
  }
  return false
}
