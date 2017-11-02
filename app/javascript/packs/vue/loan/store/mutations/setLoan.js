export default function(state, loan) {
	console.log(loan);
	state.loan = Object.assign({}, state.loan, loan);
};