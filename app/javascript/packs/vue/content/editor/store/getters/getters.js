const GetterNames = {
	ActiveOtuPanel: 'activeOtuPanel',
	ActiveRecentPanel: 'activeRecentPanel',
	ActiveTopicPanel: 'activeTopicPanel',
	GetCitationsList: 'getCitationsList',
	GetContentSelected: 'getContentSelected',
	GetDepictionsList: 'getDepictionsList',
	GetOtuSelected: 'getOtuSelected',
	GetRecent: 'getRecent',
	GetTopicSelected: 'getTopicSelected',
	PanelCitations: 'panelCitations',
	PanelFigures: 'panelFigures'
};

const GetterFunctions = { 
	[GetterNames.ActiveOtuPanel]: require('./activeOtuPanel.js'),
	[GetterNames.ActiveRecentPanel]: require('./activeRecentPanel'),
	[GetterNames.ActiveTopicPanel]: require('./activeTopicPanel'),
	[GetterNames.GetCitationsList]: require('./getCitationsList'),
	[GetterNames.GetContentSelected]: require('./getContentSelected'),
	[GetterNames.GetDepictionsList]: require('./getDepictionsList'),
	[GetterNames.GetOtuSelected]: require('./getOtuSelected'),
	[GetterNames.GetRecent]: require('./getRecent'),
	[GetterNames.GetTopicSelected]: require('./getTopicSelected'),
	[GetterNames.PanelCitations]: require('./panelCitations'),
	[GetterNames.PanelFigures]: require('./panelFigures')
};

module.exports = { 
	GetterNames,
	GetterFunctions
}