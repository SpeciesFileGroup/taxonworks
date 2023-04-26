<template>
  <div style="max-height: 450px">
    <ul class="no_bullets">
      <li>
        <label class="middle">
          <input
            name="ba-source-filter"
            type="checkbox"
            :value="unselectAll"
            @click="selected = []"
          />
          None
        </label>
      </li>
      <li
        v-for="item in list"
        :key="item.id"
      >
        <label class="middle">
          <input
            name="ba-source-filter"
            :type="type"
            :value="item.id"
            v-model="selected"
            class="button normal-input button-default"
          />
          <span v-html="item.object_tag" />
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },

  list: {
    type: Array,
    required: true
  },

  type: {
    type: String,
    default: 'checkbox'
  }
})

const emit = defineEmits(['update:modelValue'])

const selected = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

const unselectAll = computed({
  get: () => !props.modelValue.length,
  set: () => {
    selected.value = []
  }
})
</script>
