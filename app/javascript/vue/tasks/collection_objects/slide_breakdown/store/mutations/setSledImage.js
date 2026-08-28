import mergeCells from '../../helpers/mergeCells.js'

const STEP_ATTRIBUTES = [
  'step_identifier_on',
  'horizontal_step_direction',
  'vertical_step_direction'
]

export default function (state, value) {
  const stepAttributes = Object.fromEntries(
    STEP_ATTRIBUTES.map((attribute) => [attribute, state.sled_image[attribute]])
  )

  state.sled_image = {
    ...value,
    ...stepAttributes,
    metadata: mergeCells(state.sled_image.metadata, value.metadata)
  }
}
