import { convertToUnit } from 'helpers/style'

const SIZE_MAP = {
  xSmall: '12px',
  small: '16px',
  default: '24px',
  medium: '28px',
  large: '36px',
  xLarge: '40px'
}

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
      default: SIZE_MAP.default
    }
  },

  computed: {
    iconSize () {
      const sizes = {
        xSmall: this.xSmall,
        small: this.small,
        medium: this.medium,
        large: this.large,
        xLarge: this.xLarge
      }

      const explicitSize = Object.keys(sizes).find(key => sizes[key])

      return (explicitSize && SIZE_MAP[explicitSize]) || convertToUnit(this.size)
    }
  }
}
