<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <VBtn
        color="create"
        medium
        @click="addToProject"
      >
        Add to project
      </VBtn>

      <VBtn
        color="destroy"
        medium
        @click="removeFromProject"
      >
        Remove from project
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import { ProjectSource } from '@/routes/endpoints'
import { computed } from 'vue'

const MAX_LIMIT = 50

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close'])
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

function addToProject() {
  ProjectSource.batchSyncToProject({
    source_query: props.parameters,
    operation: 'add'
  })
    .then(() => {
      TW.workbench.alert.create('Sources were added to project', 'notice')
      emit('close')
    })
    .catch(() => {})
}

function removeFromProject() {
  ProjectSource.batchSyncToProject({
    source_query: props.parameters,
    operation: 'remove'
  })
    .then(() => {
      TW.workbench.alert.create('Sources were removed from project', 'notice')
      emit('close')
    })
    .catch(() => {})
}
</script>
