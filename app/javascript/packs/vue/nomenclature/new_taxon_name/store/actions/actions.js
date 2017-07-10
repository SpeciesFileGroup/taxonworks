const ActionNames = {
	SetParentAndRanks: 'setParentAndRanks',
	AddTaxonStatus: 'addTaxonStatus',
	removeTaxonStatus: 'removeTaxonStatus',
};

const ActionFunctions = {
	[ActionNames.SetParentAndRanks]: require('./setParentAndRanks'),
	[ActionNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[ActionNames.removeTaxonStatus]: require('./removeTaxonStatus'),
};

module.exports = {
	ActionNames,
	ActionFunctions
}