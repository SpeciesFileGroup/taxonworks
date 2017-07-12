const ActionNames = {
	SetParentAndRanks: 'setParentAndRanks',
	AddTaxonStatus: 'addTaxonStatus',
	removeTaxonStatus: 'removeTaxonStatus',
	RemoveSource: 'removeSource',
};

const ActionFunctions = {
	[ActionNames.SetParentAndRanks]: require('./setParentAndRanks'),
	[ActionNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[ActionNames.removeTaxonStatus]: require('./removeTaxonStatus'),
	[ActionNames.RemoveSource]: require('./removeSource'),
};

module.exports = {
	ActionNames,
	ActionFunctions
}