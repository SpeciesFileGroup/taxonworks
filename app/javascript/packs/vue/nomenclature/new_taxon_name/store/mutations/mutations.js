const MutationNames = {
	AddTaxonStatus: 'addTaxonStatus',
	RemoveTaxonStatus: 'removeTaxonStatus',
	SetModalStatus: 'setModalStatus',
	SetAllRanks: 'setAllRanks',
	SetParent: 'setParent',
	SetParentId: 'setParentId',
	SetRankClass: 'setRankClass',
	SetRankList: 'setRankList',
	SetStatusList: 'setStatusList',
	SetTaxonAuthor: 'setTaxonAuthor',
	SetTaxonName: 'setTaxonName',
	SetTaxonYearPublication: 'setTaxonYearPublication'
};

const MutationFunctions = {
	[MutationNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[MutationNames.RemoveTaxonStatus]: require('./removeTaxonStatus'),
	[MutationNames.SetModalStatus]: require('./setModalStatus'),
	[MutationNames.SetAllRanks]: require('./setAllRanks'),
	[MutationNames.SetParent]: require('./setParent'),
	[MutationNames.SetParentId]: require('./setParentId'),
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
