<template>
  <VBtn
    color="primary"
    @click="() => (isModalVisible = true)"
    :disabled="!(keep && destroy)"
  >
    Compare
  </VBtn>
  <VModal
    :container-style="{
      width: '80vw'
    }"
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Compare</h3>
    </template>
    <template #body>
      <table class="table-striped table-cells-border full_width">
        <thead>
          <tr>
            <th class="font-bold">Attribute</th>
            <th class="font-bold">Keep</th>
            <th class="font-bold">Destroy</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="attr in attributes"
            :key="attr"
            :class="{
              'text-warning-color': keep[attr] !== destroy[attr]
            }"
          >
            <td>{{ attr }}</td>
            <td v-html="keep[attr]"></td>
            <td v-html="destroy[attr]"></td>
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  keep: {
    type: Object,
    required: true
  },

  destroy: {
    type: Object,
    required: true
  }
})

const isModalVisible = ref(false)

const attributes = computed(() => {
  const exclude = ['metadata', '_metadata']
  const attrs = [
    ...Object.keys(props.key || {}),
    ...Object.keys(props.destroy || {})
  ]

  return [...new Set(attrs)].filter((attr) => !exclude.includes(attr))
})
</script>
