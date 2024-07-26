<template>
  <div>
    <VSpinner
      full-screen
      v-if="isLoading"
    />
    <slot :action="loadBibtexStyle">
      <button
        type="button"
        class="button normal-input button-default"
        :disabled="
          params.source_type !== SOURCE_BIBTEX &&
          params.source_type !== undefined
        "
        @click="loadBibtexStyle"
      >
        Download formatted
      </button>
    </slot>
    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Bibliography</h3>
      </template>
      <template #body>
        <label class="display-block">Style</label>
        <select
          class="margin-small-bottom"
          v-model="styleId"
        >
          <option
            v-for="(label, key) in bibtexStyle"
            :value="key"
            :key="key"
          >
            {{ label }}
          </option>
        </select>
        <textarea
          class="full_width"
          :value="bibtex"
        />
      </template>
      <template #footer>
        <div>
          <button
            v-if="!links"
            type="button"
            class="button normal-input button-default margin-small-right"
            :disabled="!bibtex"
            @click="generateLinks"
          >
            Generate download
          </button>
          <template v-else>
            <span>Share link:</span>
            <div class="middle">
              <pre class="margin-small-right">{{
                links.api_file_url || NO_API_MESSAGE
              }}</pre>
              <clipboard-button
                v-if="links.api_file_url"
                :text="links.api_file_url"
              />
            </div>
          </template>
          <button
            :disabled="!bibtex"
            type="button"
            @click="downloadTextFile(bibtex, 'text/bib', 'bibliography.bib')"
            class="button normal-input button-default"
          >
            Download BibTeX
          </button>
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner'
import ClipboardButton from '@/components/ui/Button/ButtonClipboard'
import { sortArray } from '@/helpers/arrays.js'
import { SOURCE_BIBTEX } from '@/constants'
import { ref, watch, computed } from 'vue'

import {
  GetBibliography,
  GetBibtexStyle,
  GetBibtex
} from '../request/resources'
import { downloadTextFile } from '@/helpers/files.js'

const props = defineProps({
  params: {
    type: Object,
    default: undefined
  },

  pagination: {
    type: Object,
    default: undefined
  },

  selectedList: {
    type: Array,
    default: () => []
  }
})

const NO_API_MESSAGE =
  'To share your project administrator must create an project API token.'

const isLoading = ref(false)
const bibtex = ref()
const links = ref()
const isModalVisible = ref(false)
const bibtexStyle = ref()
const styleId = ref()

const payload = computed(() =>
  Object.assign(
    {},
    props.selectedList.length
      ? { source_id: props.selectedList }
      : props.params,
    {
      is_public: true,
      style_id: styleId.value,
      per: props.pagination.total
    }
  )
)

watch(
  [() => props.params, () => props.selectedList],
  () => {
    links.value = undefined
    bibtex.value = undefined
    styleId.value = undefined
  },
  { deep: true }
)

watch(styleId, (newVal) => {
  if (newVal) {
    loadBibliography()
  }
})

function loadBibtexStyle() {
  if (props.params.source_type === SOURCE_BIBTEX || !props.params.source_type) {
    isModalVisible.value = true
    isLoading.value = true
    GetBibtexStyle()
      .then(({ body }) => {
        bibtexStyle.value = Object.fromEntries(
          sortArray(Object.entries(body), '1')
        )
      })
      .finally(() => {
        isLoading.value = false
      })
  }
}

function generateLinks() {
  isLoading.value = true
  GetBibliography(payload.value)
    .then(({ body }) => {
      links.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function loadBibliography() {
  isLoading.value = true

  GetBibtex(payload.value).then((response) => {
    links.value = undefined
    bibtex.value = response.body
    isLoading.value = false
  })
}
</script>

<style scoped>
:deep(.modal-container) {
  min-width: 80vw;
  min-height: 60vh;
}
textarea {
  height: 60vh;
}
</style>
