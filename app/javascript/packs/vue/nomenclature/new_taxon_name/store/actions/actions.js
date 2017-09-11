const ActionNames = {
	SetParentAndRanks: 'setParentAndRanks',
	AddTaxonStatus: 'addTaxonStatus',
	AddTaxonType: 'addTaxonType',
	AddTaxonRelationship: 'addTaxonRelationship',
	AddOriginalCombination: 'addOriginalCombination',
	CreateTaxonName: 'createTaxonName',
	UpdateTaxonName: 'updateTaxonName',
	RemoveTaxonStatus: 'removeTaxonStatus',
	RemoveTaxonRelationship: 'removeTaxonRelationship',
	RemoveOriginalCombination: 'removeOriginalCombination',
	LoadSoftValidation: 'loadSoftValidation',
	LoadTaxonName: 'loadTaxonName',
	LoadRanks: 'loadRanks',
	LoadStatus: 'loadStatus',
	LoadRelationships: 'loadRelationships',
	ChangeTaxonSource: 'changeTaxonSource',
	RemoveSource: 'removeSource',
	UpdateClassification: 'updateClassification'
};

const ActionFunctions = {
	[ActionNames.LoadSoftValidation]: require('./loadSoftValidation'),
	[ActionNames.LoadTaxonName]: require('./loadTaxonName'),
	[ActionNames.LoadRanks]: require('./loadRanks'),
	[ActionNames.LoadStatus]: require('./loadStatus'),
	[ActionNames.LoadRelationships]: require('./loadRelationships'),
	[ActionNames.SetParentAndRanks]: require('./setParentAndRanks'),
	[ActionNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[ActionNames.AddTaxonType]: require('./addTaxonType'),
	[ActionNames.AddTaxonRelationship]: require('./addTaxonRelationship'),
	[ActionNames.AddOriginalCombination]: require('./addOriginalCombination'),
	[ActionNames.CreateTaxonName]: require('./createTaxonName'),
	[ActionNames.UpdateTaxonName]: require('./updateTaxonName'),
	[ActionNames.RemoveTaxonStatus]: require('./removeTaxonStatus'),
	[ActionNames.RemoveTaxonRelationship]: require('./removeTaxonRelationship'),
	[ActionNames.RemoveOriginalCombination]: require('./removeOriginalCombination'),
	[ActionNames.RemoveSource]: require('./removeSource'),
	[ActionNames.ChangeTaxonSource]: require('./changeTaxonSource'),
	[ActionNames.UpdateClassification]: require('./updateClassification'),
};

module.exports = {
	ActionNames,
	ActionFunctions
}