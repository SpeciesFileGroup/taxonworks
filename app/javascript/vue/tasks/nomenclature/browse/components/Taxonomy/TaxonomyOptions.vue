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
          @change="(e) => updateStorage('onlyValid', e.target.checked)"
        />
        Show only valid names
      </label>
      <label class="d-block">
        <input
          type="checkbox"
          v-model="count"
          @change="(e) => updateStorage('count', e.target.checked)"
        />
        Show in/valid count *
      </label>
      <label class="d-block">
        <input
          type="checkbox"
          v-model="rainbow"
          @change="(e) => updateStorage('rainbow', e.target.checked)"
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
import { useUserPreferences } from '@/composables'
import { ref, watch } from 'vue'

const STORAGE_LAYOUT_KEY = 'tasks::BrowseNomenclature::Layout'

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
const { preferences, setPreference } = useUserPreferences()

function updateStorage(key, value) {
  setPreference(STORAGE_LAYOUT_KEY, {
    count: count.value,
    onlyValid: onlyValid.value,
    rainbow: rainbow.value,
    [key]: value
  })
}

watch(
  () => preferences.value?.layout?.[STORAGE_LAYOUT_KEY],
  (newVal) => {
    if (newVal) {
      onlyValid.value = newVal?.onlyValid
      count.value = newVal?.count
      rainbow.value = newVal?.rainbow
    }
  },
  {
    immediate: true,
    deep: true
  }
)
</script>
