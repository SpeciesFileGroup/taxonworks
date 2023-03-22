import { defineConfigs } from 'v-network-graph'

export const configs = defineConfigs({
  view: {
    boxSelectionEnabled: true
  },
  node: {
    normal: {
      type: (node) => node.type || 'circle',
      strokeDasharray: (node) => node.strokeDasharray || 0,
      strokeWidth: (node) => node.strokeWidth || 0,
      strokeColor: (node) => node.strokeColor || '#4466cc',
      color: (node) => node.color || '#4466cc'
    },
    hover: {
      color: (node) => node.hoverColor
    },
    selectable: 2
  },
  edge: {
    selectable: true,
    normal: {
      width: 3,
      color: (edge) => edge.color || '#4466cc',
      dasharray: (edge) => edge.dasharray || '0',
      linecap: 'butt',
      animate: false,
      animationSpeed: 50
    },
    hover: {
      width: 4,
      color: (edge) => edge.hoverColor || '#3355bb',
      dasharray: (edge) => edge.hoverDasharray || '0',
      linecap: 'butt',
      animate: false,
      animationSpeed: 50
    },
    selected: {
      width: 4,
      color: '#dd8800',
      dasharray: 0,
      linecap: 'round',
      animate: false,
      animationSpeed: 50
    },
    gap: 5,
    type: 'straight',
    margin: 2,
    marker: {
      source: {
        type: 'none',
        width: 4,
        height: 4,
        margin: -1,
        units: 'strokeWidth',
        color: null
      },
      target: {
        type: 'arrow',
        width: 4,
        height: 4,
        margin: -1,
        units: 'strokeWidth',
        color: null
      }
    }
  }
})
