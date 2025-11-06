<template>
  <modal-component @close="$emit('close')">
    <template #header>
      <h3>Select original citation</h3>
    </template>
    <template #body>
      <p>
        A new citation is marked as original, but another original citation
        already exists. Select one of the following actions to proceed:
      </p>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              name="handle-original"
              type="radio"
              :value="true"
              v-model="keepOriginal"
            />
            <span
              >Keep <b v-html="originalSource.cached" /> as original, save
              <b v-html="currentSource.cached" /> as non original.
            </span>
          </label>
        </li>
        <li>
          <label>
            <input
              name="handle-original"
              type="radio"
              :value="false"
              v-model="keepOriginal"
            />
            <span>
              Save <b v-html="currentSource.cached" /> as original citation.
            </span>
          </label>
        </li>
      </ul>
    </template>
    <template #footer>
      <button
        type="button"
        class="button normal-input button-submit"
        @click="handleCitation"
      >
        Save
      </button>
    </template>
  </modal-component>
</template>

<script setup>
import { ref } from 'vue'
import { Citation, Source } from '@/routes/endpoints'
import ModalComponent from '@/components/ui/Modal'

const EXTEND_PARAMS = ['source', 'citation_topics']

const props = defineProps({
  citation: {
    type: Object,
    required: true
  },

  originalCitation: {
    type: [Object, undefined],
    required: true
  }
})

const emit = defineEmits(['create', 'save', 'close'])

const currentSource = ref({})
const originalSource = ref({})
const keepOriginal = ref(true)

Source.find(props.citation.source_id).then(({ body }) => {
  currentSource.value = body
})
Source.find(props.originalCitation.source_id).then(({ body }) => {
  originalSource.value = body
})

function saveNonOriginal() {
  saveCitation({
    ...props.citation,
    is_original: false
  })
    .then(({ body }) => {
      TW.workbench.alert.create('Citation was successfully saved.', 'notice')
      emit('save', body)
      emit('close')
    })
    .catch(() => {})
}

function saveCitation(citation) {
  const citationId = citation.id
  const payload = {
    citation,
    extend: EXTEND_PARAMS
  }

  const request = citationId
    ? Citation.update(citationId, payload)
    : Citation.create(payload)

  request
    .then(({ body }) => {
      emit('save', body)
    })
    .catch(() => {})

  return request
}

async function changeOriginal() {
  try {
    await saveCitation({
      id: props.originalCitation.id,
      is_original: false
    })

    const request = saveCitation({
      ...props.citation,
      is_original: true
    })

    request.then(({ body }) => {
      TW.workbench.alert.create('Citation was successfully saved.', 'notice')
      emit('create', body)
      emit('close')
    })
  } catch {}
}

function handleCitation() {
  if (keepOriginal.value) {
    saveNonOriginal()
  } else {
    changeOriginal()
  }
}
</script>
