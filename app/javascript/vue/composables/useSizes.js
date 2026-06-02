import { computed } from 'vue'
import { convertToUnit } from '@/helpers/style'

const SIZE_NAMES = ['xxSmall', 'xSmall', 'small', 'medium', 'large', 'xLarge']

export const sizeProps = {
  xxSmall: {
    type: Boolean,
    default: false
  },

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
    default: '28px'
  }
}

export function useSizes(props) {
  const explicitSize = computed(() => SIZE_NAMES.find((name) => props[name]))

  const semanticSize = computed(() => explicitSize.value || 'default')

  const elementSize = computed(() =>
    explicitSize.value
      ? `var(--size-${explicitSize.value})`
      : convertToUnit(props.size)
  )

  return {
    explicitSize,
    semanticSize,
    elementSize
  }
}
