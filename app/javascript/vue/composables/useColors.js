import { computed } from 'vue'

const PALETTE_COLORS = new Set([
  'focus',
  'active',
  'link',
  'attention',
  'background',
  'black',
  'create',
  'data',
  'destroy',
  'error',
  'panel',
  'primary',
  'secondary',
  'update',
  'warning',
  'white',
  'border',
  'toggle-active',
  'muted'
])

export const colorProps = {
  color: {
    type: String,
    default: 'currentColor'
  }
}

export function useColors(props) {
  const selectedColor = computed(() =>
    PALETTE_COLORS.has(props.color)
      ? `var(--color-${props.color})`
      : props.color
  )

  return {
    selectedColor
  }
}
