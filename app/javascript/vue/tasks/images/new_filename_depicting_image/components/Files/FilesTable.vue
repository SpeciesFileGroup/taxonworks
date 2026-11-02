<template>
  <div class="flex-col gap-small">
    <table class="table-striped full_width">
      <thead>
        <tr>
          <th />
          <th>Filename</th>
          <th>Identifier</th>
          <th>Collection object</th>
          <th>Figure label</th>
          <th>Caption</th>
          <th>Status</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <FileRow
          v-for="row in pageRows"
          :key="row.uuid"
          :row="row"
          @remove="(r) => emit('remove', r)"
        />
      </tbody>
    </table>
    <div
      v-if="totalPages > 1"
      class="horizontal-right-content middle gap-small"
    >
      <VBtn
        small
        color="primary"
        :disabled="page === 1"
        @click="page--"
      >
        Previous
      </VBtn>
      <span>Page {{ page }} of {{ totalPages }}</span>
      <VBtn
        small
        color="primary"
        :disabled="page === totalPages"
        @click="page++"
      >
        Next
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import FileRow from './FileRow.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const PER_PAGE = 50

const props = defineProps({
  rows: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['remove'])

const page = ref(1)

const totalPages = computed(() =>
  Math.max(1, Math.ceil(props.rows.length / PER_PAGE))
)

const pageRows = computed(() =>
  props.rows.slice((page.value - 1) * PER_PAGE, page.value * PER_PAGE)
)

watch(totalPages, (value) => {
  if (page.value > value) {
    page.value = value
  }
})
</script>
