export default function (state, data) {
  state.softValidation[data.type].list = data.list
}
