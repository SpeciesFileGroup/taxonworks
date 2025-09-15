<template>
  <VBtn
    circle
    color="primary"
    @click="() => (isModalVisible = true)"
  >
    <VIcon
      name="hamburger"
      x-small
    />
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Taxonomic tree options</h3>
    </template>
    <template #body>
      <label class="d-block">
        <input
          type="checkbox"
          v-model="onlyValid"
          @change="updateStorage"
        />
        Show only valid names
      </label>
      <label class="d-block">
        <input
          type="checkbox"
          v-model="count"
          @change="updateStorage"
        />
        Show in/valid count *
      </label>
      <label class="d-block">
        <input
          type="checkbox"
          v-model="rainbow"
          @change="updateStorage"
        />
        Level-based coloring
      </label>
      <p>
        <i>* You may need to reload the page for this option to take effect.</i>
      </p>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { convertType } from '@/helpers'
import { onBeforeMount, ref } from 'vue'

const count = defineModel('count', {
  type: Boolean,
  required: true
})

const onlyValid = defineModel('onlyValid', {
  type: Boolean,
  required: true
})

const rainbow = defineModel('rainbow', {
  type: Boolean,
  required: true
})

const isModalVisible = ref(false)

const STORAGE_COUNT_KEY = 'TW::TaxonomyTree::Count'
const STORAGE_ONLY_VALID_KEY = 'TW::TaxonomyTree::OnlyValid'
const STORAGE_RAINBOW_KEY = 'TW::TaxonomyTree::RainbowMode'

function updateStorage() {
  localStorage.setItem(STORAGE_COUNT_KEY, count.value)
  localStorage.setItem(STORAGE_ONLY_VALID_KEY, onlyValid.value)
  localStorage.setItem(STORAGE_RAINBOW_KEY, rainbow.value)
}

onBeforeMount(() => {
  const c = convertType(localStorage.getItem(STORAGE_COUNT_KEY))
  const r = convertType(localStorage.getItem(STORAGE_RAINBOW_KEY))
  const v = convertType(localStorage.getItem(STORAGE_ONLY_VALID_KEY))

  if (v !== null) {
    onlyValid.value = v
  }

  if (c !== null) {
    count.value = c
  }

  if (r !== null) {
    rainbow.value = r
  }
})
</script>
