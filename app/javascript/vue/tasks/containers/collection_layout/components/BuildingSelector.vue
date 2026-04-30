<template>
  <section class="building-section">
    <h3>Building</h3>

    <div
      v-if="modelValue"
      class="horizontal-left-content gap-small middle"
    >
      <strong v-html="modelValue.object_tag || modelValue.name" />
      <RadialAnnotator :global-id="modelValue.global_id" />
      <VBtn
        color="primary"
        medium
        @click="onClear"
      >
        Change
      </VBtn>
    </div>

    <div
      v-else
      class="horizontal-left-content gap-small middle flex-wrap"
    >
      <VAutocomplete
        url="/containers/autocomplete"
        placeholder="Find existing building…"
        param="term"
        label="label"
        :add-param="{ type: 'Container::Building' }"
        @get-item="onSelectExisting"
      />
      <span class="building-divider">or</span>
      <input
        v-model="name"
        type="text"
        placeholder="New building name"
        class="normal-input"
      />
      <label>
        x
        <input
          v-model.number="sizeX"
          type="number"
          min="1"
          placeholder="none"
          class="normal-input small-input"
        />
      </label>
      <label>
        y
        <input
          v-model.number="sizeY"
          type="number"
          min="1"
          placeholder="none"
          class="normal-input small-input"
        />
      </label>
      <label>
        z
        <input
          v-model.number="sizeZ"
          type="number"
          min="1"
          placeholder="none"
          class="normal-input small-input"
        />
      </label>
      <VBtn
        color="create"
        medium
        :disabled="!name.trim()"
        @click="createBuilding"
      >
        Create
      </VBtn>
      <RecentBuildings @select="onSelectFromRecent" />
      <span
        v-if="error"
        class="feedback-warning"
        >{{ error }}</span
      >
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RecentBuildings from './RecentBuildings.vue'

defineProps({
  modelValue: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue'])

const name = ref('')
const sizeX = ref(null)
const sizeY = ref(null)
const sizeZ = ref(null)
const error = ref('')

function resetForm() {
  name.value = ''
  sizeX.value = null
  sizeY.value = null
  sizeZ.value = null
  error.value = ''
}

async function onSelectExisting({ id }) {
  error.value = ''
  const { body } = await AjaxCall('get', `/containers/${id}.json`)
  if (body?.id) {
    emit('update:modelValue', body)
  } else {
    error.value = 'Could not load building.'
  }
}

function onSelectFromRecent(item) {
  emit('update:modelValue', item)
}

async function createBuilding() {
  error.value = ''

  const attrs = { type: 'Container::Building', name: name.value.trim() }
  if (sizeX.value) attrs.size_x = sizeX.value
  if (sizeY.value) attrs.size_y = sizeY.value
  if (sizeZ.value) attrs.size_z = sizeZ.value

  const { body } = await AjaxCall('post', '/containers.json', {
    container: attrs
  })
  if (body?.id) {
    resetForm()
    emit('update:modelValue', body)
  } else {
    error.value = 'Could not create building.'
  }
}

function onClear() {
  resetForm()
  emit('update:modelValue', null)
}
</script>

<style scoped>
.building-section {
  margin-bottom: 1em;
}

.building-divider {
  color: #999;
}

.small-input {
  width: 7em;
}
</style>
