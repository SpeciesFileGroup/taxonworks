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
      />
    </template>
    <template #footer>
      <VBtn
        medium
        color="primary"
        @click="() => emit('update:name', graphName)"
        @keyup.enter="() => emit('update:name', graphName)"
      >
        Set
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  graph: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:name'])

const graphName = ref(props.graph.name)
const inputName = ref()

onMounted(() => {
  inputName.value.focus()
})
</script>
