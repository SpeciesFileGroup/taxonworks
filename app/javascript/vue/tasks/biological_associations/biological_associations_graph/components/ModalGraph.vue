<template>
  <VModal>
    <template #header>
      <h3>Graph</h3>
    </template>
    <template #body>
      <label class="display-block">Name</label>
      <input
        class="full_width"
        type="text"
        ref="inputName"
        v-model="graphName"
        @keyup.enter="handleUpdateName"
      />
    </template>
    <template #footer>
      <VBtn
        medium
        color="primary"
        @click="handleUpdateName"
      >
        Set
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  graph: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:name'])

const graphName = ref(props.graph.name)
const inputName = ref()

function handleUpdateName() {
  emit('update:name', graphName.value)
}

onMounted(() => {
  nextTick(() => {
    inputName.value.focus()
  })
})
</script>
