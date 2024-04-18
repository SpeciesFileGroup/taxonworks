import editableLeftRightFields from '../constants/editableLeftRightFields'

export default function() {
  if (
    this.left && this.right && (
      !sameOriginLabels(
        this.last_saved.origin_label,
        this.lead.origin_label
      ) ||
      !sameEditableValues(this.last_saved.left, this.left) ||
      !sameEditableValues(this.last_saved.right, this.right)
    )
  ) {
    return true
  }
  return false
}

function sameOriginLabels(l1, l2) {
  if (!l1 && !l2) { // null ~ ''
    return true
  }
  return l1 == l2
}

function sameEditableValues(obj1, obj2) {
  for (const field of editableLeftRightFields) {
    if (!obj1[field] && !obj2[field]) { // null ~ ''
      continue
    }
    if (obj1[field] != obj2[field]) {
      return false
    }
  }
  return true
}
