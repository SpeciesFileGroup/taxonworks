const ActionNames = {
	SetParentAndRanks: 'setParentAndRanks',
	AddTaxonStatus: 'addTaxonStatus',
	AddTaxonRelationship: 'addTaxonRelationship',
	AddOriginalCombination: 'addOriginalCombination',
	RemoveTaxonStatus: 'removeTaxonStatus',
	RemoveTaxonRelationship: 'removeTaxonRelationship',
	RemoveOriginalCombination: 'removeOriginalCombination',
	LoadSoftValidation: 'loadSoftValidation',
	ChangeTaxonSource: 'changeTaxonSource',
	RemoveSource: 'removeSource',
};

const ActionFunctions = {
	[ActionNames.LoadSoftValidation]: require('./loadSoftValidation'),
	[ActionNames.SetParentAndRanks]: require('./setParentAndRanks'),
	[ActionNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[ActionNames.AddTaxonRelationship]: require('./addTaxonRelationship'),
	[ActionNames.AddOriginalCombination]: require('./addOriginalCombination'),
	[ActionNames.RemoveTaxonStatus]: require('./removeTaxonStatus'),
	[ActionNames.RemoveTaxonRelationship]: require('./removeTaxonRelationship'),
	[ActionNames.RemoveOriginalCombination]: require('./removeOriginalCombination'),
	[ActionNames.RemoveSource]: require('./removeSource'),
	[ActionNames.ChangeTaxonSource]: require('./changeTaxonSource'),
};

module.exports = {
	ActionNames,
	ActionFunctions
}