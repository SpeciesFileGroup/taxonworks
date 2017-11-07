import setLoan from './setLoan';
import setLoanItems from './setLoanItems';
import addLoanItem from './addLoanItem';
import setLoading from './setLoading';
import setSaving from './setSaving';
import removeLoanItem from './removeLoanItem';


const MutationNames = {
	AddLoanItem: 'addLoanItem',
	SetLoan: 'setLoan',
	SetLoanItems: 'setLoanItems',
	SetLoading: 'setLoading',
	SetSaving: 'setSaving',
	RemoveLoanItem: 'removeLoanItem'
};

const MutationFunctions = {
	[MutationNames.AddLoanItem]: addLoanItem,
	[MutationNames.SetLoan]: setLoan,
	[MutationNames.SetLoanItems]: setLoanItems,
	[MutationNames.SetLoading]: setLoading,
	[MutationNames.SetSaving]: setSaving,
	[MutationNames.RemoveLoanItem]: removeLoanItem
};

export {
	MutationNames,
	MutationFunctions
}