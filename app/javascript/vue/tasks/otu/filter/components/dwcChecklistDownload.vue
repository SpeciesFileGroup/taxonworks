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
          <p>
            <i>Only OTUs linked to DwcOccurrences (by Collection Object or Field
            Occurrence determination or Asserted Distribution OTU) will be
            included in the checklist.</i>
          </p>

          <div class="panel content">
            <p class="margin-small-bottom"><strong>Select extensions to include:</strong></p>
            <ul class="no_bullets">
              <li
                v-for="item in availableExtensions"
                :key="item.value"
              >
                <label>
                  <input
                    type="checkbox"
                    v-model="selectedExtensions[item.value]"
                    @change="handleExtensionChange(item.value)"
                  />
                  {{ item.label }}
                </label>
              </li>
            </ul>
          </div>

          <div
            v-if="selectedExtensions.description"
            class="panel content margin-medium-top"
          >
            <p class="margin-small-bottom"><strong>Select topics for descriptions (in order):</strong></p>
            <p class="subtle margin-small-bottom">
              <i>Only published (public) contents will be included in the export.</i>
            </p>
            <VBtn
              color="primary"
              medium
              class="margin-small-bottom"
              style="align-self: flex-start;"
              @click="showTopicModal = true"
            >
              Add Topics
            </VBtn>
            <ul
              v-if="selectedTopics.length"
              class="no_bullets"
            >
              <li
                v-for="(topic, index) in selectedTopics"
                :key="topic.id"
                class="margin-small-bottom flex-separate middle"
              >
                <span>{{ index + 1 }}. {{ topic.name }}</span>
                <VBtn
                  circle
                  color="primary"
                  @click="removeTopic(index)"
                >
                  <VIcon
                    x-small
                    color="white"
                    name="trash"
                  />
                </VBtn>
              </li>
            </ul>
            <p
              v-else
              class="subtle"
            >
              No topics selected. Click "Add Topics" to select topics.
            </p>
          </div>

          <div class="panel content margin-medium-top">
            <p class="margin-small-bottom"><strong>How to handle unaccepted names:</strong></p>
            <div
              v-for="option in acceptedNameModeOptions"
              :key="option.value"
            >
              <label>
                <input
                  type="radio"
                  v-model="acceptedNameMode"
                  :value="option.value"
                />
                {{ option.label }}
              </label>
            </div>
          </div>
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
    <v-modal
      v-if="showTopicModal"
      @close="showTopicModal = false"
      :container-style="{ width: '600px', height: '70vh' }"
    >
      <template #header>
        <h3>Select Topic</h3>
      </template>
      <template #body>
        <TopicList @select="addTopic" />
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
import VIcon from '@/components/ui/VIcon/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import TopicList from '@/tasks/contents/editor/components/Topic/TopicList.vue'
import { humanize } from '@/helpers'

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
const acceptedNameModeOptions = ref([])
const acceptedNameMode = ref('replace_with_accepted_name')
const showTopicModal = ref(false)
const selectedTopics = ref([])

onMounted(async () => {
  try {
    isLoadingExtensions.value = true

    // Fetch extensions
    const { body: extensions } = await DwcChecklist.checklistExtensions()
    availableExtensions.value = extensions
      .map(cur => {
        const label = humanize(cur.value) + (cur.displayed_in_gbif ? '' : ' (not displayed in GBIF\'s checklist UI)')
        return {
          value: cur.value,
          label: label,
          displayed_in_gbif: cur.displayed_in_gbif
        }
      })
      // Sort: GBIF extensions first (alphabetically), then non-GBIF (alphabetically)
      .sort((a, b) => {
        if (a.displayed_in_gbif === b.displayed_in_gbif) {
          return a.label.localeCompare(b.label)
        }
        return a.displayed_in_gbif ? -1 : 1
      })

    // Initialize only GBIF-displayed extensions as checked by default
    extensions.forEach(ext => {
      selectedExtensions[ext.value] = ext.displayed_in_gbif
    })

    // Fetch accepted name mode options
    const { body: modeOptions } = await DwcChecklist.acceptedNameModeOptions()
    acceptedNameModeOptions.value = modeOptions

    // Set default to first option if available
    if (modeOptions.length > 0) {
      acceptedNameMode.value = modeOptions[0].value
    }
  } catch (error) {
    console.error('Failed to load checklist options:', error)
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
    extensions,
    accepted_name_mode: acceptedNameMode.value
  }

  // Add description topics if description extension is selected
  if (selectedExtensions.description && selectedTopics.value.length > 0) {
    payload.description_topics = selectedTopics.value.map(t => t.id)
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

function addTopic(topic) {
  // Avoid duplicates
  if (!selectedTopics.value.find(t => t.id === topic.id)) {
    selectedTopics.value.push(topic)
    TW.workbench.alert.create(`Added topic: ${topic.name}`, 'notice')
  } else {
    TW.workbench.alert.create(`Topic "${topic.name}" is already selected`, 'notice')
  }
  // Keep modal open to allow selecting multiple topics
}

function removeTopic(index) {
  selectedTopics.value.splice(index, 1)
}

function handleExtensionChange(extensionValue) {
  // Clear topics if description extension is unchecked
  if (extensionValue === 'description' && !selectedExtensions[extensionValue]) {
    selectedTopics.value = []
  }
}

</script>
