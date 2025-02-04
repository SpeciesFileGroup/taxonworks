<template>
  <div class="horizontal-left-content">
    <div class="field label-above full_width margin-small-right">
      <label>{{ title }}</label>
      <input
        class="full_width"
        type="text"
        :disabled="disabled"
        v-model="params[param]"
      />
    </div>
    <div class="field">
      <br />
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          :value="param"
          :disabled="disabled"
          v-model="personWildcard"
        />
        Wildcard
      </label>
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue'

defineProps({
  title: {
    type: String,
    required: true
  },

  param: {
    type: String,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const personWildcard = computed({
  get() {
    return params.value.person_wildcard || []
  },

  set(value) {
    params.value.personWildcard = value
  }
})

onMounted(() => {})
</script>
