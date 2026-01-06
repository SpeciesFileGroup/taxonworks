<template>
  <modal-component
    @close="$emit('close', true)"
    :containerStyle="{ 'overflow-y': 'scroll', 'max-height': '80vh' }"
    class="full_width"
  >
    <template #header>
      <h3>Create a source from a verbatim citation or DOI</h3>
    </template>
    <template #body>
      <spinner-component
        v-if="isSearching"
        :full-screen="true"
        legend="Searching..."
      />
      <ul>
        <li>Submit either a DOI or full citation.</li>
        <li>
          DOIs should be in one of the following forms:
          <pre>
https://doi.org/10.1145/3274442
10.1145/3274442
doi:10.1145/3274442
</pre
          >
        </li>
        <li>
          The query will be resolved against
          <a href="https://www.crossref.org/">CrossRef</a>.
        </li>
        <li>
          If there is a hit, then you will be given the option to import the
          parsed citation. This is the BibTeX format.
        </li>
        <li>
          If there is no hit, you have the option to import the record as a
          single field. This is the Verbatim format.
        </li>
        <li>
          The created source is automatically added to the current project.
        </li>
        <li>
          <em
            >Not all hits are correct! Check that the result matches the
            query.</em
          >
        </li>
      </ul>
      <textarea
        ref="textarea"
        class="full_width"
        v-model="citation"
        placeholder="DOI or citation to find..."
      />
    </template>
    <template #footer>
      <div class="flex-separate separate-top">
        <button
          @click="getSource"
          :disabled="!citation.length"
          class="button normal-input button-default"
          type="button"
        >
          Find
        </button>
        <button
          v-if="!found"
          type="button"
          class="button normal-input button-default"
          @click="setVerbatim"
        >
          Set as verbatim
        </button>
      </div>
    </template>
  </modal-component>
</template>

<script setup>
import AjaxCall from '@/helpers/ajaxCall'
import SpinnerComponent from '@/components/ui/VSpinner'
import ModalComponent from '@/components/ui/Modal'
import { nextTick, ref, onMounted, useTemplateRef } from 'vue'
import { Serial } from '@/routes/endpoints'
import { useSourceStore } from '../store'
import { SOURCE_VERBATIM } from '@/constants'

const emit = defineEmits(['close'])

const store = useSourceStore()
const citation = ref('')
const found = ref(true)
const isSearching = ref(false)

const textareaRef = useTemplateRef('textarea')

onMounted(() => {
  nextTick(() => {
    textareaRef.value.focus()
  })
})

function getSource() {
  isSearching.value = true
  store.reset()

  AjaxCall(
    'get',
    `/tasks/sources/new_source/crossref_preview.json?citation=${citation.value}`
  )
    .then(({ body }) => {
      if (body.title) {
        store.reset()

        store.setSource(body)

        if (body.journal) {
          Serial.where({ name: body.journal }).then((response) => {
            const [serial] = response.body

            if (serial) {
              store.source.serial_id = serial.id
              store.source.isUnsaved = true
            }
          })
        }
        emit('close', true)
        TW.workbench.alert.create('Found! (please check).', 'notice')
      } else {
        found.value = false
        TW.workbench.alert.create(
          'Nothing found, the Source already exists, or the result found could not be processed as BibTeX.',
          'error'
        )
      }
    })
    .catch(() => {})
    .finally(() => {
      isSearching.value = false
    })
}

function setVerbatim() {
  store.reset({
    type: SOURCE_VERBATIM,
    verbatim: citation.value
  })
  emit('close', true)
}
</script>

<style scoped>
:deep(.modal-container) {
  width: 500px;
}
textarea {
  height: 100px;
}
</style>
