<template>
  <div class="range">
    <input
      class="range__slider"
      ref="rangeInput"
      type="range"
      v-model.number="inputValue"
      :min="min"
      :max="max"
      :step="step"
      @mouseup="emit('input:mouseup', $event)"
    >
    <output
      ref="rangeTooltip"
      :value="inputValue"
      class="range__slider-tooltip"
      :class="{'range__slider-tooltip-only-hover': hover }"
    >
      {{ inputValue }}
    </output>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'

const props = defineProps({
  modelValue: {
    type: Number,
    required: true
  },

  min: {
    type: [Number, String],
    required: true
  },

  max: {
    type: [Number, String],
    required: true
  },

  step: {
    type: [Number, String],
    default: 1
  },

  hover: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'update:modelValue',
  'input:mouseup'
])

const rangeInput = ref(null)
const rangeTooltip = ref(null)

const inputValue = computed({
  get () {
    return props.modelValue
  },

  set (value) {
    emit('update:modelValue', value)
  }
})

const setTooltipPosition = () => {
  const min = Number(props.min)
  const max = Number(props.max)
  const value = Number(inputValue.value)

  const newPosition = Number(((value - min) * 100) / (max - min))

  rangeTooltip.value.style.left = `calc(${newPosition}% + (${8 - newPosition * 0.15}px))`;
}

watch(
  inputValue,
  () => setTooltipPosition()
)

onMounted(() => {
  setTooltipPosition()
})

</script>

<style scoped lang="scss">
.range {
  position: relative;

  &__slider-tooltip {
    padding: 4px 12px;
    position: absolute;
    border-radius: 4px;
    left: 50%;
    transform: translateX(-50%);
    background: #122C35;
    color: white;
    bottom: -28px;
  }

  &__slider-tooltip:before {
    content: '';
    display: block;
    position: absolute;
    top: -8px;
    left: 0;
    right: 0;
    margin: 0 auto;
    width: 0;
    height: 0;
    border-style: solid;
    border-width: 0 4px 8px 4px;
    border-color: transparent transparent #122C35 transparent;
  }

  &__slider-tooltip-only-hover {
    display: none;
  }

  &__slider {
    width: 100%;
    padding: 0px;
    border: 0px
  }

  &__slider:hover ~ &__slider-tooltip-only-hover {
    display: block;
  }
}
</style>
