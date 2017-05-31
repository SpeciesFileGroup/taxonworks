const MutationNames = {
	AddTaxonStatus: 'addTaxonStatus',
	AddTaxonRelationship: 'addTaxonRelationship',
	RemoveTaxonStatus: 'removeTaxonStatus',
	RemoveTaxonRelationship: 'removeTaxonRelationship',
	SetModalStatus: 'setModalStatus',
	SetModalRelationship: 'setModalRelationship',
	SetAllRanks: 'setAllRanks',
	SetParent: 'setParent',
	SetParentId: 'setParentId',
	SetRankClass: 'setRankClass',
	SetRankList: 'setRankList',
	SetRelationshipList: 'setRelationshipList',
	SetStatusList: 'setStatusList',
	SetTaxonAuthor: 'setTaxonAuthor',
	SetTaxonName: 'setTaxonName',
	SetTaxonYearPublication: 'setTaxonYearPublication'
};

const MutationFunctions = {
	[MutationNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[MutationNames.AddTaxonRelationship]: require('./addTaxonRelationship'),
	[MutationNames.RemoveTaxonStatus]: require('./removeTaxonStatus'),
	[MutationNames.RemoveTaxonRelationship]: require('./removeTaxonRelationship'),
	[MutationNames.SetModalStatus]: require('./setModalStatus'),
	[MutationNames.SetModalRelationship]: require('./setModalRelationship'),
	[MutationNames.SetAllRanks]: require('./setAllRanks'),
	[MutationNames.SetParent]: require('./setParent'),
	[MutationNames.SetParentId]: require('./setParentId'),
	[MutationNames.SetRelationshipList]: require('./setRelationshipList'),
	[MutationNames.SetRankClass]: require('./setRankClass'),
	[MutationNames.SetRankList]: require('./setRankList'),
	[MutationNames.SetStatusList]: require('./setStatusList'),
	[MutationNames.SetTaxonAuthor]: require('./setTaxonAuthor'),
	[MutationNames.SetTaxonName]: require('./setTaxonName'),
	[MutationNames.SetTaxonYearPublication]: require('./setTaxonYearPublication'),
};

module.exports = {
	MutationNames,
	MutationFunctions
};
