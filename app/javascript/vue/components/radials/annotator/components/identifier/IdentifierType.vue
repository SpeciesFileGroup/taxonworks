<template>
  <fieldset>
    <legend>Type</legend>
    <VSwitch
      :options="Object.values(TABS)"
      v-model="tabSelected"
    />

    <div class="separate-top">
      <ul class="no_bullets">
        <li
          v-for="(item, key) in types[tabSelected]"
          :key="key"
        >
          <label class="capitalize">
            <input
              type="radio"
              v-model="type"
              :value="key"
            >
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>

    <p
      v-if="type"
      class="capitalize"
    >
      Type: {{ types.all[type].label }}
    </p>
  </fieldset>
</template>

<script setup>
import { computed, ref } from 'vue'
import VSwitch from 'components/switch.vue'

const props = defineProps({
  types: {
    type: Object,
    default: () => ({})
  },

  list: {
    type: String,
    default: undefined
  },

  modelValue: {
    type: String,
    default: undefined
  }
})

const TABS = {
  Common: 'common',
  All: 'all'
}

const tabSelected = ref(TABS.Common)

const emit = defineEmits(['update:modelValue'])

const type = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
