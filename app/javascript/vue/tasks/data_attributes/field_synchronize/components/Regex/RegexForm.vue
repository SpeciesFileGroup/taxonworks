<template>
  <div class="horizontal-left-content gap-medium">
    <div>
      <label> From </label>
      <select v-model="from">
        <option
          :value="undefined"
          selected
        >
          None
        </option>
        <option
          v-for="attribute in attributes"
          :key="attribute"
        >
          {{ attribute }}
        </option>
        <hr />
        <option
          v-for="predicate in predicates"
          :key="predicate.id"
          :value="predicate"
        >
          {{ predicate.name }}
        </option>
      </select>
    </div>

    <div>
      <label>To</label>
      <select v-model="to">
        <option
          :value="undefined"
          selected
        >
          None
        </option>
        <option
          v-for="attribute in attributes"
          :key="attribute"
        >
          {{ attribute }}
        </option>
        <hr />
        <option
          v-for="predicate in predicates"
          :key="predicate.id"
          :value="predicate"
        >
          {{ predicate.name }}
        </option>
      </select>
    </div>

    <div class="horizontal-left-content gap-medium">
      <VBtn
        color="primary"
        medium
        @click="() => addPattern({ replace: false })"
        >Add pattern</VBtn
      >
      <MatchReplaceForm
        v-for="(item, index) in patterns"
        :key="item.uuid"
        v-model="patterns[index]"
        @remove="() => patterns.splice(index, 1)"
      />
    </div>
  </div>
</template>

<script setup>
import MatchReplaceForm from './MatchReplaceForm.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { randomUUID } from '@/helpers'

defineProps({
  attributes: {
    type: Array,
    default: () => []
  },

  predicates: {
    type: Array,
    default: () => []
  }
})

const to = defineModel('to', {
  type: [String, Object],
  default: undefined
})

const from = defineModel('from', {
  type: [String, Object],
  default: undefined
})

const patterns = defineModel({
  type: Array,
  default: () => []
})

function addPattern({ replace }) {
  patterns.value.push({
    uuid: randomUUID(),
    match: '',
    value: '',
    replace
  })
}
</script>
