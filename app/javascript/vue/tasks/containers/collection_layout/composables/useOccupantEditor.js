import { reactive } from 'vue'
import { Container } from '@/routes/endpoints'

const EMPTY_FORM = {
  name: '',
  percentEmpty: null,
  percentEarmarked: null,
  printLabel: '',
  error: ''
}

export function useOccupantEditor() {
  const editForm = reactive({ ...EMPTY_FORM })

  function reset() {
    Object.assign(editForm, EMPTY_FORM)
  }

  async function loadFrom(occupant) {
    reset()
    if (!occupant) return
    const { body } = await Container.find(occupant.id)
    if (body?.id) {
      editForm.name = body.name || ''
      editForm.percentEmpty = body.asserted_percent_empty ?? null
      editForm.percentEarmarked = body.asserted_percent_earmarked ?? null
      editForm.printLabel = body.print_label || ''
    }
  }

  // Save a single field. % fields are sent together so cross-field validation
  // (earmarked must not exceed empty) has both values to compare against.
  async function saveField(occupantId, field, value) {
    if (!occupantId) return null
    editForm.error = ''

    const attrs = { [field]: value }
    if (field === 'asserted_percent_empty')
      attrs.asserted_percent_earmarked = editForm.percentEarmarked
    if (field === 'asserted_percent_earmarked')
      attrs.asserted_percent_empty = editForm.percentEmpty

    let body
    try {
      ;({ body } = await Container.update(occupantId, { container: attrs }))
    } catch (error) {
      const errors = error?.response?.body
      editForm.error = errors
        ? Object.values(errors).flat().join(', ')
        : 'Could not save.'
      return null
    }

    return body
  }

  function setPercent(formKey, apiField, value, occupantId) {
    editForm[formKey] = value
    return saveField(occupantId, apiField, value)
  }

  return { editForm, loadFrom, saveField, setPercent, reset }
}
