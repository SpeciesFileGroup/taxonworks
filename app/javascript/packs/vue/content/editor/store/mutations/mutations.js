const MutationNames = {
	AddCitationToList: 'addCitationToList',
	AddDepictionToList: 'addDepictionToList',
	AddToRecentContents: 'addToRecentContents',
	AddToRecentTopics: 'addToRecentTopics',
	ChangeStateCitations: 'changeStateCitations',
	ChangeStateFigures: 'changeStateFigures',
	OpenOtuPanel: 'openOtuPanel',
	RemoveCitation: 'removeCitation',
	RemoveDepiction: 'removeDepiction',
	SetCitationList: 'setCitationList',
	SetContent: 'setContent',
	SetContentSelected: 'setContentSelected',
	SetDepictionsList: 'setDepictionsList',
	SetOtuSelected: 'setOtuSelected',
	SetRecentContents: 'setRecentContents',
	SetRecentOtus: 'setRecentOtus',
	SetRecentTopics: 'setRecentTopics',
	SetTopicSelected: 'setTopicSelected'
};

const MutationFunctions = {
	[MutationNames.AddCitationToList]: require('./addCitationToList'),
	[MutationNames.AddDepictionToList]: require('./addDepictionToList'),
	[MutationNames.AddToRecentContents]: require('./addToRecentContents'),
	[MutationNames.AddToRecentTopics]: require('./addToRecentTopics'),
	[MutationNames.ChangeStateCitations]: require('./changeStateCitations'),
	[MutationNames.ChangeStateFigures]: require('./changeStateFigures'),
	[MutationNames.OpenOtuPanel]: require('./openOtuPanel'),
	[MutationNames.RemoveCitation]: require('./removeCitation'),
	[MutationNames.RemoveDepiction]: require('./removeDepiction'),
	[MutationNames.SetCitationList]: require('./setCitationList'),
	[MutationNames.SetContent]: require('./setContent'),
	[MutationNames.SetContentSelected]: require('./setContentSelected'),
	[MutationNames.SetDepictionsList]: require('./setDepictionsList'),
	[MutationNames.SetOtuSelected]: require('./setOtuSelected'),
	[MutationNames.SetRecentContents]: require('./setRecentContents'),
	[MutationNames.SetRecentOtus]: require('./setRecentOtus'),
	[MutationNames.SetRecentTopics]: require('./setRecentTopics'),
	[MutationNames.SetTopicSelected]: require('./setTopicSelected'),
};

module.exports = {
	MutationNames,
	MutationFunctions
}