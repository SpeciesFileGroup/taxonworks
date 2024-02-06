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
    type: Object,
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

function createNonOriginal() {
  const payload = {
    citation: {
      ...props.citation,
      is_original: false
    },
    extend: EXTEND_PARAMS
  }

  Citation.create(payload).then(({ body }) => {
    emit('save', body)
    emit('close')
  })
}

function changeOriginal() {
  const payload = {
    citation: {
      id: props.originalCitation.id,
      is_original: false
    },
    extend: EXTEND_PARAMS
  }

  Citation.update(props.originalCitation.id, payload).then(({ body }) => {
    emit('save', body)

    Citation.create({
      citation: { ...props.citation, is_original: true }
    }).then(({ body }) => {
      emit('save', body)
      emit('create', body)
      emit('close')
    })
  })
}

function handleCitation() {
  if (keepOriginal.value) {
    createNonOriginal()
  } else {
    changeOriginal()
  }
}
</script>
