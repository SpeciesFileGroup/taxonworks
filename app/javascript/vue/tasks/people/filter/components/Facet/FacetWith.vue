<template>
  <div>
    <h3 class="capitalize">{{ param.replaceAll('_', ' ') }}</h3>
    <ul class="no_bullets">
      <li
        v-for="(func, key) in OPTIONS"
        :key="key"
      >
        <label
          @click="func"
          :checked="key === selectedOption"
        >
          <input
            type="radio"
            :checked="selectedOption === key"
          >
          {{ key }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  param: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,

  set: value => emit('update:modelValue', value)
})

const selectedOption = computed(() => {
  const inWith = params.value.with.includes(props.param)
  const inWithout = params.value.without.includes(props.param)

  if (inWith) return 'with'
  if (inWithout) return 'without'

  return 'both'
})

const OPTIONS = {
  both: () => {
    params.value.with = params.value.with.filter(item => item !== props.param)
    params.value.without = params.value.without.filter(item => item !== props.param)
  },

  with: () => {
    params.value.with = [...new Set([...params.value.with, props.param])]
    params.value.without = params.value.without.filter(item => item !== props.param)
  },

  without: () => {
    params.value.with = params.value.with.filter(item => item !== props.param)
    params.value.without = [...new Set([...params.value.without, props.param])]
  }
}

const {
  with: withParams = [],
  without = []
} = URLParamsToJSON(location.href)

if (withParams.includes(props.param)) {
  params.value.with.push(props.param)
}

if (without.includes(props.param)) {
  params.value.without.push(props.param)
}

</script>
