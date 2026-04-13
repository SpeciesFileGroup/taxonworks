<template>
  <div>
    <slot :action="action">
      <v-btn
        color="primary"
        medium
        @click="setModalView(true)"
      >
        Download DwC
      </v-btn>
    </slot>
    <v-modal
      @close="setModalView(false)"
      :container-style="{ width: '700px', minHeight: '200px' }"
      v-if="showModal"
    >
      <template #header>
        <h3>Download DwC</h3>
      </template>
      <template #body>
        <v-spinner
          v-if="isLoading"
          legend="Loading predicates..."
        />
        <ul class="no_bullets">
          <li
            v-for="item in checkboxParameters"
            :key="item.parameter"
          >
            <label>
              <input
                type="checkbox"
                v-model="includeParameters[item.parameter]"
              />
              {{ item.label }}
            </label>
          </li>
        </ul>
        <div class="margin-small-top">
          <h3>Filter by predicates</h3>
        </div>
        <PredicateFilter
          v-model:collecting-event-predicate-id="predicateParams.collecting_event_predicate_id"
          v-model:collection-object-predicate-id="predicateParams.collection_object_predicate_id"
          v-model:taxonworks-extension-methods="selectedExtensionMethods.taxonworks_extension_methods"
        />

        <div class="margin-medium-top">
          <VBtn
            color="create"
            medium
            @click="download"
          >
            Download
          </VBtn>
        </div>
      </template>
    </v-modal>
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>
<script setup>
import { reactive, ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import { DwcOcurrence } from '@/routes/endpoints'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import PredicateFilter from '@/components/Export/PredicateFilter.vue'

const checkboxParameters = [
  {
    label: 'Include biological associations as resource relationship',
    parameter: 'biological_associations_extension'
  },
  {
    label: 'Include media extension',
    parameter: 'media_extension',
  }
]

const props = defineProps({
  params: {
    type: Object,
    required: true
  },

  total: {
    type: Number,
    required: true
  },

  selectedIds: {
    type: Array,
    default: () => []
  },

  nestParameter: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['create'])

const confirmationModalRef = ref()
const showModal = ref(false)
const isLoading = ref(false)
const includeParameters = ref({})
const predicateParams = reactive({
  collecting_event_predicate_id: [],
  collection_object_predicate_id: []
})
const selectedExtensionMethods = reactive({
  taxonworks_extension_methods: []
})

const getFilterParams = (params) => {
  const entries = Object.entries({ ...params, ...predicateParams }).filter(
    ([key, value]) => !Array.isArray(value) || value.length
  )
  const data = Object.fromEntries(entries)

  data.per = props.total
  delete data.page

  return data
}

function download() {
  const downloadParams = props.selectedIds.length
    ? { collection_object_id: props.selectedIds }
    : getFilterParams(props.params)

  const payload = {
    ...includeParameters.value,
    ...predicateParams,
    ...selectedExtensionMethods
  }

  if (props.nestParameter) {
    Object.assign(payload, { [props.nestParameter]: downloadParams })
  } else {
    Object.assign(payload, downloadParams)
  }

  DwcOcurrence.generateDownload(payload)
    .then(({ body }) => {
      emit('create', body)
      openGenerateDownloadModal()
    })
    .catch(() => {})
}

function setModalView(value) {
  showModal.value = value
}

function action() {
  setModalView(true)
}

async function openGenerateDownloadModal() {
  await confirmationModalRef.value.show({
    title: 'Generating Download',
    message: `It will be available shortly on the <a href="${RouteNames.DwcDashboard}">DwC Dashboard</a>`,
    okButton: 'Close',
    typeButton: 'default'
  })

  setModalView(false)
}

</script>
<style>
.dwc-download-predicates {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 1em;
}
</style>
