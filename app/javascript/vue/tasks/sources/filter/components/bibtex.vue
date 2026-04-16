<template>
  <div>
    <spinner-component
      v-if="isLoading"
      full-screen
    />
    <slot :action="loadBibtex">
      <button
        type="button"
        class="button normal-input button-default"
        :disabled="
          params.source_type != SOURCE_BIBTEX && params.source_type != undefined
        "
        @click="loadBibtex"
      >
        BibTeX
      </button>
    </slot>
    <modal-component
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Bibtex</h3>
      </template>
      <template #body>
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
            @click="generateLinks"
          >
            Generate download
          </button>
          <template v-else>
            <span>Share link:</span>
            <div class="middle">
              <pre class="margin-small-right">{{
                links.api_file_url ? links.api_file_url : NO_API_MESSAGE
              }}</pre>
              <clipboard-button
                v-if="links.api_file_url"
                :text="links.api_file_url"
              />
            </div>
          </template>
          <button
            class="button normal-input button-default"
            type="button"
            :disabled="!bibtex"
            @click="downloadTextFile(bibtex, 'text/bib', 'source.bib')"
          >
            Download Bibtex
          </button>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import ModalComponent from '@/components/ui/Modal'
import SpinnerComponent from '@/components/ui/VSpinner'
import ClipboardButton from '@/components/ui/Button/ButtonClipboard'
import { SOURCE_BIBTEX } from '@/constants'
import { GetBibtex, GetGenerateLinks } from '../request/resources'
import { ref, watch, computed } from 'vue'
import { downloadTextFile } from '@/helpers/files.js'

const NO_API_MESSAGE =
  'To share your project administrator must create a project API token.'

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

const isModalVisible = ref(false)
const links = ref()
const isLoading = ref(false)
const bibtex = ref()

watch(
  [() => props.params, () => props.selectedList],
  () => {
    links.value = undefined
  },
  {
    deep: true
  }
)

const payload = computed(() =>
  Object.assign(
    {},
    props.selectedList.length
      ? { source_id: props.selectedList }
      : props.params,
    {
      per: props.pagination.total
    }
  )
)

function loadBibtex() {
  isModalVisible.value = true
  isLoading.value = true

  GetBibtex(payload.value)
    .then(({ body }) => {
      bibtex.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function generateLinks() {
  isLoading.value = true
  GetGenerateLinks({ ...payload.value, is_public: true }).then((response) => {
    links.value = response.body
    isLoading.value = false
  })
}
</script>
<style scoped>
textarea {
  height: 60vh;
}

:deep(.modal-container) {
  min-width: 80vw;
  min-height: 60vh;
}
</style>
