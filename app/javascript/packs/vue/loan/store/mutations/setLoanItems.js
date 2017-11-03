export default function(state, loan_items) {
		console.log(loan_items);
	state.loan_items = Object.assign({}, state.loan_items, loan_items);
};