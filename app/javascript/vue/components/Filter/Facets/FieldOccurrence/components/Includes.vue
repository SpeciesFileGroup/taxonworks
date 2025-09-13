<template>
  <h3>Includes</h3>
  <ul class="no_bullets">
    <li
      v-for="item in INCLUDES"
      :key="item"
    >
      <label>
        <input
          type="checkbox"
          :value="item"
          :disabled="!params.field_occurrence_id?.length"
          v-model="foScope"
        />
        {{ humanize(item) }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed, watch } from 'vue'
import { humanize } from '@/helpers/strings'

const INCLUDES = ['field_occurrences', 'observations', 'collecting_events']

const params = defineModel({
  type: Object,
  required: true
})

const foScope = computed({
  get: () => params.value.field_occurrence_scope || [],
  set: (value) => {
    params.value.field_occurrence_scope = value
  }
})

watch(
  () => params.value.field_occurrence_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      foScope.value = []
    }
  }
)
</script>
