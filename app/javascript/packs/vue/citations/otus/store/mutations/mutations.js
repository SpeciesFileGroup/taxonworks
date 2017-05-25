const MutationNames = {
	AddCitation: 'addCitation',
	AddToOtuList: 'addToOtuList',
	AddTopicSelected: 'addTopicSelected',
	AddToSourceList: 'addToSourceList',
	RemoveCitationSelected: 'removeCitationSelected',
	RemoveOtuFormCitationList: 'removeOtuFormCitationList',
	RemoveSourceFormCitationList: 'removeSourceFormCitationList',
	RemoveTopicSelected: 'removeTopicSelected',
	SetCitationsList: 'setCitationsList',
	SetCurrentCitation: 'setCurrentCitation',
	SetOtuCitationsList: 'setOtuCitationsList',
	SetOtuSelected: 'setOtuSelected',
	SetSourceCitationsList: 'setSourceCitationsList',
	SetSourceSelected: 'setSourceSelected',
	SetTopicsList: 'setTopicsList',
	SetTopicsSelected: 'setTopicsSelected'
};

const MutationFunctions = {
	[MutationNames.AddCitation]: require('./addCitation'),
	[MutationNames.AddToOtuList]: require('./addToOtuList'),
	[MutationNames.AddTopicSelected]: require('./addTopicSelected'),
	[MutationNames.AddToSourceList]: require('./addToSourceList'),
	[MutationNames.RemoveCitationSelected]: require('./removeCitationSelected'),
	[MutationNames.RemoveOtuFormCitationList]: require('./removeOtuFormCitationList'),
	[MutationNames.RemoveSourceFormCitationList]: require('./removeSourceFormCitationList'),
	[MutationNames.RemoveTopicSelected]: require('./removeTopicSelected'),
	[MutationNames.SetCitationsList]: require('./setCitationsList'),
	[MutationNames.SetCurrentCitation]: require('./setCurrentCitation'),
	[MutationNames.SetOtuCitationsList]: require('./setOtuCitationsList'),
	[MutationNames.SetOtuSelected]: require('./setOtuSelected'),
	[MutationNames.SetSourceCitationsList]: require('./setSourceCitationsList'),
	[MutationNames.SetSourceSelected]: require('./setSourceSelected'),
	[MutationNames.SetTopicsList]: require('./setTopicsList'),
	[MutationNames.SetTopicsSelected]: require('./setTopicsSelected')
};

module.exports = {
	MutationNames,
	MutationFunctions
}