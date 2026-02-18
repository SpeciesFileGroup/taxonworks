<template>
  <div class="dwc-compact-form panel content">
    <h3>Filter parameters</h3>
    <p class="subtle">
      Pass DwcOccurrence filter parameters to scope the data.
      Use the Radial Linker from a filter task to auto-populate.
    </p>

    <div class="field">
      <label>OTU ID(s)</label>
      <input
        v-model="formParams.otu_id"
        type="text"
        placeholder="Comma-separated IDs"
      >
    </div>

    <div class="field">
      <label>Taxon name ID</label>
      <input
        v-model="formParams.taxon_name_id"
        type="text"
        placeholder="Taxon name ID"
      >
    </div>

    <div class="field">
      <label>Collection object query (JSON)</label>
      <textarea
        v-model="rawCollectionObjectQuery"
        rows="3"
        placeholder='{"collecting_event_query": {...}}'
      />
    </div>

    <div class="dwc-compact-form-actions">
      <button
        class="button normal-input button-submit"
        :disabled="isLoading"
        @click="emitCompact"
      >
        Compact
      </button>
      <button
        class="button normal-input button-default"
        :disabled="isLoading"
        @click="emitPreview"
      >
        Preview (validate only)
      </button>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'

const props = defineProps({
  isLoading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['compact', 'preview'])

const formParams = reactive({
  otu_id: '',
  taxon_name_id: ''
})

const rawCollectionObjectQuery = ref('')

function buildParams() {
  const params = {}

  if (formParams.otu_id) {
    params.otu_id = formParams.otu_id.split(',').map((s) => s.trim())
  }

  if (formParams.taxon_name_id) {
    params.taxon_name_id = formParams.taxon_name_id
      .split(',')
      .map((s) => s.trim())
  }

  if (rawCollectionObjectQuery.value) {
    try {
      params.collection_object_query = JSON.parse(
        rawCollectionObjectQuery.value
      )
    } catch {
      // ignore invalid JSON
    }
  }

  return params
}

function emitCompact() {
  emit('compact', buildParams())
}

function emitPreview() {
  emit('preview', buildParams())
}
</script>

<style scoped>
.dwc-compact-form {
  margin-bottom: 1em;
}

.dwc-compact-form .field {
  margin-bottom: 0.5em;
}

.dwc-compact-form .field label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.25em;
}

.dwc-compact-form .field input,
.dwc-compact-form .field textarea {
  width: 100%;
  max-width: 500px;
}

.dwc-compact-form-actions {
  margin-top: 1em;
  display: flex;
  gap: 0.5em;
}

.subtle {
  color: #666;
  font-size: 0.9em;
}
</style>
