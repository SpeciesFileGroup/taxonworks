<template>
  <VModal
    :container-style="{ width: '500px' }"
    @close="emit('close')"
  >
    <template #header>
      <h3>Layout settings</h3>
    </template>
    <template #body>
      <VDraggable
        v-model="allPanels"
        handle=".handle"
        :item-key="(element) => element"
        @end="syncSections"
      >
        <template #item="{ element }">
          <div>
            <label class="handle cursor-grab">
              <input
                type="checkbox"
                :checked="sections.includes(element)"
                @change="toggleSection(element)"
              />
              {{ PANEL_COMPONENTS[element]?.title }}
            </label>
          </div>
        </template>
      </VDraggable>
    </template>
    <template #footer>
      <VBtn
        color="primary"
        @click="
          () => {
            taskPreferences.sections = Object.keys(PANEL_COMPONENTS)
            setPreference(props.storageKey, taskPreferences)
          }
        "
        >Reset</VBtn
      >
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { PANEL_COMPONENTS } from '../../constants'
import { useUserPreferences } from '@/composables'
import VModal from '@/components/ui/Modal.vue'
import VDraggable from 'vuedraggable'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  preferences: {
    type: Object,
    required: true
  },

  storageKey: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['close'])

const { setPreference } = useUserPreferences()

const taskPreferences = computed(
  () => props.preferences?.layout?.[props.storageKey]
)

const sections = computed(() => taskPreferences.value?.sections || [])

const allPanels = ref([
  ...sections.value,
  ...Object.keys(PANEL_COMPONENTS).filter((key) => !sections.value.includes(key))
])

function syncSections() {
  if (!taskPreferences.value) return

  taskPreferences.value.sections = allPanels.value.filter((key) =>
    sections.value.includes(key)
  )

  setPreference(props.storageKey, taskPreferences.value)
}

function toggleSection(key) {
  if (!taskPreferences.value) return

  if (sections.value.includes(key)) {
    taskPreferences.value.sections = sections.value.filter((k) => k !== key)
  } else {
    const newSections = allPanels.value.filter(
      (k) => sections.value.includes(k) || k === key
    )

    taskPreferences.value.sections = newSections
  }

  setPreference(props.storageKey, taskPreferences.value)
}
</script>
