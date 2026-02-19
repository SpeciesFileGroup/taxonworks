<template>
  <div class="anatomical-part-subject-table-block anatomical-part-summary">
    <div class="horizontal-left-content middle gap-small">
      <h3 class="anatomical-part-heading anatomical-part-summary-heading">
        <span>Anatomical parts of</span>
        <span
          class="anatomical-part-heading-object"
          v-html="subjectHeadingHtml"
        />
        <span>as subject:</span>
      </h3>
      <VBtn
        color="primary"
        @click="showModal = true"
      >
        View table ({{ list.length }})
      </VBtn>
    </div>
  </div>

  <VModal
    v-if="showModal"
    @close="showModal = false"
  >
    <template #header>
      <h3 class="anatomical-part-heading margin-remove">
        <span>Anatomical parts of</span>
        <span
          class="anatomical-part-heading-object"
          v-html="subjectHeadingHtml"
        />
        <span>as subject</span>
      </h3>
    </template>
    <template #body>
      <div class="ap-table-modal-body">
        <TableAnatomicalPartMode
          :list="list"
          :metadata="metadata"
          @delete="emit('delete', $event)"
        />
      </div>
    </template>
  </VModal>
</template>

<script setup>
import TableAnatomicalPartMode from '../table_anatomical_part_mode.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import { ref } from 'vue'

defineProps({
  list: {
    type: Array,
    required: true
  },
  metadata: {
    type: Object,
    required: true
  },
  subjectHeadingHtml: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['delete'])

const showModal = ref(false)
</script>
