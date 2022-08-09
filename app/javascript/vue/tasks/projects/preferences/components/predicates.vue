<template>
  <div>
    <h2>Attributes (predicates) to include</h2>
    <draggable
      class="no_bullets"
      tag="ul"
      item-key="id"
      :list="list"
      :disabled="!model"
      @end="updateList"
    >
      <template #item="{ element }">
        <li>
          <label :key="element.id">
            <input
              type="checkbox"
              :value="element.id"
              v-model="selected"
              :disabled="!model"
              @change="updateList"
            >
            <span v-html="element.object_tag" />
          </label>
        </li>
      </template>
    </draggable>
  </div>
</template>

<script setup>

import Draggable from 'vuedraggable'
import { ref, watch } from 'vue'

const props = defineProps({
  modelList: {
    type: Array,
    default: () => []
  },

  list: {
    type: Array,
    default: () => []
  },

  model: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits([
  'update',
  'sort'
])

const selected = ref([])

watch(
  () => props.modelList,
  newVal => { selected.value = newVal }
)

const updateList = () => {
  emit('update', {
    [props.model]: selected.value,
    predicate_index: props.list.map(({ id }) => id)
  })
}

</script>
