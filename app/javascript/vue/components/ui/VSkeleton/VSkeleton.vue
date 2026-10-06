<template>
  <div
    v-if="isMultiLine"
    class="skeleton-group"
    :style="groupStyle"
    aria-hidden="true"
    role="presentation"
  >
    <span
      v-for="(lineWidth, i) in lineWidths"
      :key="i"
      :class="[
        'skeleton',
        `skeleton--${variant}`,
        { 'skeleton--rounded': rounded, 'skeleton--animated': animated }
      ]"
      :style="{ width: lineWidth }"
    />
  </div>

  <span
    v-else
    :class="[
      'skeleton',
      `skeleton--${variant}`,
      { 'skeleton--rounded': rounded, 'skeleton--animated': animated }
    ]"
    :style="computedStyle"
    aria-hidden="true"
    role="presentation"
  />
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'text',
    validator: (v) =>
      [
        'text',
        'title',
        'circle',
        'rect',
        'card',
        'button',
        'badge',
        'thumbnail'
      ].includes(v)
  },

  lines: {
    type: [Number, Array],
    default: 1
  },

  gap: {
    type: String,
    default: '10px'
  },

  width: {
    type: String,
    default: null
  },

  height: {
    type: String,
    default: null
  },

  rounded: {
    type: Boolean,
    default: false
  },

  animated: {
    type: Boolean,
    default: true
  }
})

const isMultiLine = computed(() => {
  if (Array.isArray(props.lines)) return props.lines.length > 0
  return props.lines > 1
})

const lineWidths = computed(() => {
  if (Array.isArray(props.lines)) return props.lines

  const count = Math.max(1, props.lines)
  return Array.from({ length: count }, (_, i) =>
    i === count - 1 && count > 1 ? '65%' : '100%'
  )
})

const groupStyle = computed(() => ({
  display: 'flex',
  flexDirection: 'column',
  gap: props.gap,
  width: props.width ?? '100%'
}))

const computedStyle = computed(() => ({
  ...(props.width && { width: props.width }),
  ...(props.height && { height: props.height })
}))
</script>

<style scoped>
.skeleton {
  --sk-radius: 6px;
  --sk-speed: 1.6s;

  display: block;
  background-color: var(--sk-base);
  border-radius: var(--sk-radius);
  overflow: hidden;
  position: relative;
  flex-shrink: 0;
}

.skeleton--animated::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    105deg,
    transparent 35%,
    var(--sk-shine) 50%,
    transparent 65%
  );
  background-size: 250% 100%;
  animation: sk-shimmer var(--sk-speed) ease-in-out infinite;
}

@keyframes sk-shimmer {
  0% {
    background-position: 150% 0;
  }
  100% {
    background-position: -150% 0;
  }
}

.skeleton--text {
  width: 100%;
  height: 14px;
  border-radius: 4px;
}
.skeleton--title {
  width: 60%;
  height: 22px;
  border-radius: 4px;
}
.skeleton--circle {
  width: 42px;
  height: 42px;
  border-radius: 50%;
}
.skeleton--rect {
  width: 100%;
  height: 80px;
}
.skeleton--card {
  width: 100%;
  height: 180px;
  border-radius: 12px;
}
.skeleton--button {
  width: 110px;
  height: 38px;
  border-radius: 8px;
}
.skeleton--badge {
  width: 64px;
  height: 22px;
  border-radius: 999px;
}
.skeleton--thumbnail {
  width: 72px;
  height: 72px;
  border-radius: 8px;
}

.skeleton--rounded {
  border-radius: 999px !important;
}
</style>
