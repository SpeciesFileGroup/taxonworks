import { convertToUnit } from 'helpers/style'

export default {
  props: {
    xSmall: {
      type: Boolean,
      default: false
    },

    small: {
      type: Boolean,
      default: false
    },

    medium: {
      type: Boolean,
      default: false
    },

    large: {
      type: Boolean,
      default: false
    },

    xLarge: {
      type: Boolean,
      default: false
    },

    size: {
      type: [Number, String],
      default: '24px'
    }
  },

  data () {
    return {
      SIZE_MAP: {
        xSmall: '12px',
        small: '16px',
        default: '24px',
        medium: '28px',
        large: '36px',
        xLarge: '40px'
      }
    }
  },

  computed: {
    explicitSize () {
      const sizes = {
        xSmall: this.xSmall,
        small: this.small,
        medium: this.medium,
        large: this.large,
        xLarge: this.xLarge
      }

      return Object.keys(sizes).find(key => sizes[key])
    },

    semanticSize () {
      return this.explicitSize || 'default'
    },

    elementSize () {
      return (this.explicitSize && this.SIZE_MAP[this.explicitSize]) || convertToUnit(this.size)
    }
  }
}
