<template>
  <BlockLayout>
    <template #header>
      <h3>Match/Replace</h3>
    </template>
    <template #body>
      <div>
        <label class="d-block">From</label>
        <select v-model="from">
          <option
            :value="undefined"
            selected
          >
            None
          </option>
          <option
            v-for="attribute in isExtract ? editableAttributes : attributes"
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
        <label class="d-block">To</label>
        <select v-model="to">
          <option
            :value="undefined"
            selected
          >
            None
          </option>
          <option
            v-for="attribute in editableAttributes"
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

      <div class="flex-col gap-medium margin-medium-top">
        <MatchReplaceForm
          v-for="(item, index) in patterns"
          :key="item.uuid"
          :index="index"
          v-model="patterns[index]"
          @remove="() => patterns.splice(index, 1)"
        />

        <i>* When extract pattern is set, others will be ignored</i>
        <div class="horizontal-left-content gap-small">
          <VBtn
            v-for="(value, key) in PATTERN_TYPES"
            :key="key"
            color="primary"
            :disabled="
              isExtract ||
              (value === PATTERN_TYPES.Extract &&
                (toExclude.includes(to) ||
                  toExclude.includes(from) ||
                  to == from))
            "
            medium
            @click="() => addPattern({ mode: value })"
          >
            {{ key }}
          </VBtn>
        </div>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import MatchReplaceForm from './MatchReplaceForm.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { randomUUID } from '@/helpers'
import { PATTERN_TYPES } from '../../constants'
import { computed } from 'vue'

const props = defineProps({
  toExclude: {
    type: Array,
    default: () => []
  },

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

const isExtract = computed(() =>
  patterns.value.some((item) => item.mode === PATTERN_TYPES.Extract)
)

const editableAttributes = computed(() =>
  props.attributes.filter((item) => !props.toExclude.includes(item))
)

function addPattern({ mode }) {
  patterns.value.push({
    uuid: randomUUID(),
    match: '',
    value: '',
    mode
  })
}
</script>
