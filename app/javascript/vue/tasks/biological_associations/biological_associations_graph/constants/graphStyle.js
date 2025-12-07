const DEFAULT_NODE_STYLE = {
  color: '#3355bb',
  hoverColor: '#3355bb'
}

export const unsavedEdge = {
  color: '#9ca5a7',
  dasharray: 5,
  hoverColor: '#dedede',
  hoverDasharray: 5
}

export const unsavedNodeStyle = {
  strokeDasharray: 5,
  strokeWidth: 2,
  strokeColor: '#9ca5a7',
  color: '#dfdfdf',
  hoverColor: '#dedede'
}

export const nodeCollectionObjectStyle = {
  ...DEFAULT_NODE_STYLE,
  color: '#2196F3',
  type: 'rect'
}

export const nodeFieldOccurrenceStyle = {
  ...DEFAULT_NODE_STYLE,
  color: '#32a852',
  type: 'rect'
}

export const nodeOtuStyle = {
  ...DEFAULT_NODE_STYLE,
  type: 'circle',
  color: '#96a832'
}

export const nodeAnatomicalPartStyle = {
  ...DEFAULT_NODE_STYLE,
  type: 'circle',
  color: '#ffaa00'
}
