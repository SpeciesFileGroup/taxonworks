import { convertToUnit } from 'helpers/style'
import SIZE_MAP from 'assets/styles/variables/_sizes.scss'

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
      return (this.explicitSize && SIZE_MAP[this.explicitSize]) || convertToUnit(this.size)
    }
  }
}
