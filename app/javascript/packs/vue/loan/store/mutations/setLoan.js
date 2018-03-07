export default function (state, loan) {
  state.loan = Object.assign({}, state.loan, loan)
};
