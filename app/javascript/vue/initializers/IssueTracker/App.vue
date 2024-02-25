<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
    :container-style="{
      width: '700px'
    }"
  >
    <template #header>
      <h3>Report a problem</h3>
    </template>
    <template #body>
      <h4>My issue is with:</h4>
      <ul>
        <li
          v-for="item in URLs"
          :key="item.label"
        >
          <a
            :href="item.url"
            target="_blank"
            :title="item.description"
          >
            {{ item.label }}
          </a>
          {{ item.description }}
        </li>
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import { ref, onMounted, onBeforeUnmount, defineOptions } from 'vue'

defineOptions({
  name: 'IssueTracker'
})

const props = defineProps({
  element: {
    type: HTMLElement,
    required: true
  }
})

const URLs = [
  {
    label: 'Data',
    description:
      "E.g. missing data that I'd like to add, misspellings, or invalid data",
    url: props.element.getAttribute('data-curation-issue-tracker')
  },
  {
    label: 'Website',
    description:
      'E.g. a link, task, or other feature is not working as expected',
    url: 'https://github.com/SpeciesFileGroup/taxonworks/issues'
  }
]

const isModalVisible = ref(false)

function openModal(e) {
  e.preventDefault()

  isModalVisible.value = true
}

onMounted(() => {
  props.element.addEventListener('click', openModal)
})

onBeforeUnmount(() => {
  props.element.removeEventListener('click', openModal)
})
</script>
