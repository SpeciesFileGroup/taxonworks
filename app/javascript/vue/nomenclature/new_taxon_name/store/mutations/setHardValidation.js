export default function (state, value) {
  if (value) {
    state.hardValidation = Object.assign({}, state.hardValidation, value)
  } else {
    state.hardValidation = undefined
  }
}
