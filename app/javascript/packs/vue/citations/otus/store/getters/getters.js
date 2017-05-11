const GetterNames = {
	GetCitationSelected: 'getCitationSelected',
	GetCitationsList: 'getCitationsList',
	GetOtuCitationsList: 'getOtuCitationsList',
	GetOtuSelected: 'getOtuSelected',
	GetSetTopics: 'getSetTopics',
	GetSourceCitationsList: 'getSourceCitationsList',
	GetSourceSelected: 'getSourceSelected',
	GetTopicsList: 'getTopicsList',
	ObjectsSelected: 'objectsSelected'
}

const GetterFunctions = {
	[GetterNames.GetCitationSelected]: require('./getCitationSelected'),
	[GetterNames.GetCitationsList]: require('./getCitationsList'),
	[GetterNames.GetOtuCitationsList]: require('./getOtuCitationsList'),
	[GetterNames.GetOtuSelected]: require('./getOtuSelected'),
	[GetterNames.GetSetTopics]: require('./getSetTopics'),
	[GetterNames.GetSourceCitationsList]: require('./getSourceCitationsList'),
	[GetterNames.GetSourceSelected]: require('./getSourceSelected'),
	[GetterNames.GetTopicsList]: require('./getTopicsList'),
	[GetterNames.ObjectsSelected]: require('./objectsSelected')
}

module.exports = {
	GetterNames,
	GetterFunctions
}