const ActionNames = {
	SetParentAndRanks: 'setParentAndRanks',
};

const ActionFunctions = {
	[ActionNames.SetParentAndRanks]: require('./setParentAndRanks'),
};

module.exports = {
	ActionNames,
	ActionFunctions
}