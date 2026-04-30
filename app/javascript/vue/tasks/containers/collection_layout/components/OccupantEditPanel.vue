<template>
  <div class="modal-col-edit">
    <h4>Edit</h4>

    <label class="edit-field">
      Name
      <input
        v-model="editForm.name"
        type="text"
        class="full_width"
        @blur="onSave('name', editForm.name)"
      />
    </label>

    <div class="edit-field">
      <span class="edit-label">% empty</span>
      <div class="slider-track-row">
        <input
          v-model.number="editForm.percentEmpty"
          type="range"
          min="0"
          max="100"
          step="1"
          class="range-input"
          @change="onSave('asserted_percent_empty', editForm.percentEmpty)"
        />
        <span class="slider-value">{{ editForm.percentEmpty ?? '—' }}</span>
      </div>
      <div class="slider-btn-row">
        <VBtn
          v-for="pct in [25, 50, 100]"
          :key="pct"
          color="primary"
          small
          @click="onSetPercent('percentEmpty', 'asserted_percent_empty', pct)"
          >{{ pct }}</VBtn
        >
      </div>
    </div>

    <div class="edit-field">
      <span class="edit-label">% earmarked</span>
      <div class="slider-track-row">
        <input
          v-model.number="editForm.percentEarmarked"
          type="range"
          min="0"
          max="100"
          step="1"
          class="range-input"
          @change="
            onSave('asserted_percent_earmarked', editForm.percentEarmarked)
          "
        />
        <span class="slider-value">{{ editForm.percentEarmarked ?? '—' }}</span>
      </div>
      <div class="slider-btn-row">
        <VBtn
          v-for="pct in [25, 50, 100]"
          :key="pct"
          color="primary"
          small
          @click="
            onSetPercent('percentEarmarked', 'asserted_percent_earmarked', pct)
          "
          >{{ pct }}</VBtn
        >
      </div>
    </div>

    <label class="edit-field">
      <span class="edit-label">Print label</span>
      <textarea
        v-model="editForm.printLabel"
        rows="3"
        class="full_width"
        @blur="onSave('print_label', editForm.printLabel)"
      />
    </label>

    <span
      v-if="editForm.error"
      class="feedback-warning"
      >{{ editForm.error }}</span
    >
  </div>
</template>

<script setup>
import { watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { useOccupantEditor } from '../composables/useOccupantEditor'

const props = defineProps({
  occupant: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['updated'])

const { editForm, loadFrom, saveField, setPercent } = useOccupantEditor()

watch(
  () => props.occupant?.id,
  async () => {
    await loadFrom(props.occupant)
  },
  { immediate: true }
)

async function onSave(field, value) {
  if (!props.occupant) return
  const body = await saveField(props.occupant.id, field, value)
  if (body) emit('updated', { field, body })
}

function onSetPercent(formKey, apiField, value) {
  if (!props.occupant) return
  setPercent(formKey, apiField, value, props.occupant.id).then((body) => {
    if (body) emit('updated', { field: apiField, body })
  })
}
</script>

<style scoped>
.modal-col-edit {
  flex: 0 0 300px;
  min-width: 0;
  overflow: hidden;
  border-left: 1px solid #eee;
  padding-left: 1.5em;
  display: flex;
  flex-direction: column;
  gap: 0.75em;
}

.modal-col-edit h4 {
  margin: 0 0 0.25em;
}

.edit-field {
  display: flex;
  flex-direction: column;
  gap: 0.25em;
  font-size: 0.9em;
  min-width: 0;
}

.edit-label {
  font-weight: normal;
}

.slider-track-row {
  display: flex;
  align-items: center;
  gap: 0.4em;
  overflow: hidden;
  min-width: 0;
}

.range-input {
  flex: 1 1 0;
  min-width: 0;
  width: 0;
}

.slider-value {
  flex: 0 0 2.5em;
  text-align: right;
  font-size: 0.85em;
  color: #555;
}

.slider-btn-row {
  display: flex;
  gap: 0.3em;
}
</style>
