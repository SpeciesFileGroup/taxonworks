import setLoan from './setLoan';
import setLoanItems from './setLoanItems';
import addLoanItem from './addLoanItem';
import addEditLoanItem from './addEditLoanItem';
import setLoading from './setLoading';
import setSaving from './setSaving';
import removeLoanItem from './removeLoanItem';


const MutationNames = {
	AddLoanItem: 'addLoanItem',
	AddEditLoanItem: 'addEditLoanItem',
	SetLoan: 'setLoan',
	SetLoanItems: 'setLoanItems',
	SetLoading: 'setLoading',
	SetSaving: 'setSaving',
	RemoveLoanItem: 'removeLoanItem'
};

const MutationFunctions = {
	[MutationNames.AddLoanItem]: addLoanItem,
	[MutationNames.AddEditLoanItem]: addEditLoanItem,
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