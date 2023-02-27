import { defineConfigs } from 'v-network-graph'

export const configs = defineConfigs({
  view: {
    boxSelectionEnabled: true
  },
  node: {
    selectable: 2
  },
  edge: {
    selectable: 1,
    normal: {
      width: 3,
      color: (node) => node.color || '#4466cc',
      dasharray: (node) => node.dasharray || '0',
      linecap: 'butt',
      animate: false,
      animationSpeed: 50
    },
    hover: {
      width: 4,
      color: '#3355bb',
      dasharray: '0',
      linecap: 'butt',
      animate: false,
      animationSpeed: 50
    },
    selected: {
      width: 3,
      color: '#dd8800',
      dasharray: '6',
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
