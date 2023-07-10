<template>
  <div></div>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '1240px' }"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Citations</h3>
    </template>
    <template #body>
      <CitationForm
        class="margin-medium-bottom"
        :submit-button="{
          label: 'Add',
          color: 'primary'
        }"
        @submit="(item) => citations.push({ ...item })"
      />
      <DisplayList
        label="_label"
        soft-delete
        :warning="false"
        :list="citations"
        @delete-index="(index) => citations.splice(index, 1)"
      />
    </template>
  </VModal>
  <VBtn
    color="primary"
    medium
    @click="() => (isModalVisible = true)"
  >
    Citations ({{ citations.length }})
  </VBtn>
</template>

<script setup>
import { ref, computed } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import CitationForm from 'components/Form/FormCitation.vue'
import DisplayList from 'components/displayList.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const citations = computed({
  get: () => props.modelValue,
  set: (value) => {
    emit('update:modelValue', value)
  }
})

const isModalVisible = ref(false)
</script>
