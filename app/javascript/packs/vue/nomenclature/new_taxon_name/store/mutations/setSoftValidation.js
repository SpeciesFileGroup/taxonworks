module.exports = function (state, validation) {
  state.softValidation[validation.type].list = validation.response
}
