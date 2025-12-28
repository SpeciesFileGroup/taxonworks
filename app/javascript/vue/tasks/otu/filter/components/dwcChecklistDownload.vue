<template>
  <div>
    <slot :action="action">
      <v-btn
        color="primary"
        medium
        @click="setModalView(true)"
      >
        Download DwC Checklist
      </v-btn>
    </slot>
    <v-modal
      @close="setModalView(false)"
      :container-style="{ width: '500px', minHeight: '200px' }"
      v-if="showModal"
    >
      <template #header>
        <h3>Download DwC Checklist</h3>
      </template>
      <template #body>
        <v-spinner
          v-if="isLoadingExtensions"
          legend="Loading extensions..."
        />
        <div v-else>
          <p class="margin-small-bottom">Select extensions to include:</p>
          <ul class="no_bullets">
            <li
              v-for="item in availableExtensions"
              :key="item.value"
            >
              <label>
                <input
                  type="checkbox"
                  v-model="selectedExtensions[item.value]"
                />
                {{ item.label }}
              </label>
            </li>
          </ul>
        </div>

        <div class="margin-medium-top">
          <VBtn
            color="create"
            medium
            @click="download"
            :disabled="isLoadingExtensions"
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
import { onMounted, reactive, ref } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import { DwcChecklist } from '@/routes/endpoints'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  params: {
    type: Object,
    required: true
  },

  total: {
    type: Number,
    default: 0
  },

  selectedIds: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['create'])

const confirmationModalRef = ref()
const showModal = ref(false)
const isLoadingExtensions = ref(false)
const availableExtensions = ref([])
const selectedExtensions = reactive({})

onMounted(async () => {
  try {
    isLoadingExtensions.value = true
    const { body } = await DwcChecklist.checklistExtensions()
    availableExtensions.value = body

    // Initialize all extensions as checked by default
    body.forEach(ext => {
      selectedExtensions[ext.value] = true
    })
  } catch (error) {
    console.error('Failed to load checklist extensions:', error)
  } finally {
    isLoadingExtensions.value = false
  }
})

const getFilterParams = (params) => {
  const data = { ...params }

  if (props.total) {
    data.per = props.total
    delete data.page
  }

  return data
}

function download() {
  const downloadParams = props.selectedIds.length
    ? { otu_id: props.selectedIds }
    : getFilterParams(props.params)

  // Get list of enabled extensions
  const extensions = Object.entries(selectedExtensions)
    .filter(([_, enabled]) => enabled)
    .map(([extension]) => extension)

  const payload = {
    otu_query: downloadParams,
    extensions
  }

  console.log('Sending payload:', payload)

  DwcChecklist.generateChecklistDownload(payload).then(({ body }) => {
    console.log('Success response:', body)
    emit('create', body)
    openGenerateDownloadModal()
  }).catch((error) => {
    console.error('Error generating checklist download:', error)
    console.error('Error details:', error.response?.data)
    alert(`Error generating download: ${error.response?.data?.error || error.message}`)
  })
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
