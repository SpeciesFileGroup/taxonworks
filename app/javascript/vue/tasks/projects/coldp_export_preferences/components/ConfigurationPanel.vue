<template>
  <div class="panel padding-large">
    <h2>Configuration</h2>
    <div class="margin-medium-left">
      <div class="field">
        <label>Root OTU</label>
        <Autocomplete
          url="/otus/autocomplete"
          label="label_html"
          display="label"
          min="2"
          placeholder="Select root OTU"
          param="term"
          :send-label="otuLabel"
          @getItem="setOtu"
        />
      </div>

      <div class="field margin-medium-top">
        <label>ChecklistBank Dataset</label>
        <div class="position-relative margin-small-top">
          <input
            type="text"
            v-model="clbSearchQuery"
            placeholder="Search ChecklistBank datasets..."
            class="full_width"
            @input="onClbInput"
            @keydown.delete="onClbBackspace"
          />
          <ul
            v-if="clbResults.length > 0 && clbSearchOpen"
            class="vue-autocomplete-list"
          >
            <li
              v-for="dataset in clbResults"
              :key="dataset.key"
              class="d-flex flex-column gap-xsmall cursor-pointer padding-xsmall"
              @click="selectClbDataset(dataset)"
            >
              <div class="d-flex align-items-center">
                <span class="font-bold line-nowrap">#{{ dataset.key }}</span>
                <span v-if="dataset.alias" class="line-nowrap"> ({{ dataset.alias }})</span>
              </div>
              <span class="ellipsis">{{ dataset.title }}</span>
            </li>
          </ul>
        </div>
      </div>

      <div class="field margin-medium-top">
        <label>Base URL for taxon page links</label>
        <input
          type="text"
          :value="profile.base_url"
          @input="emit('update:profile', {
            ...profile,
            base_url: $event.target.value
          })"
          placeholder=""
          class="full_width margin-small-top"
        />
        <div class="small_type">
          Use <code>{otu_id}</code> as a placeholder for the OTU ID, e.g. <code>https://hoppers.speciesfile.org/otus/{otu_id}/overview</code>
        </div>
      </div>

      <div class="field margin-medium-top">
        <label>
          <input
            type="checkbox"
            :checked="profile.is_public"
            @change="emit('update:profile', {
              ...profile,
              is_public: $event.target.checked
            })"
          />
          Is Public
        </label>
      </div>

      <div class="field margin-medium-top">
        <label>
          <input
            type="checkbox"
            :checked="profile.fossil_extinct"
            @change="emit('update:profile', {
              ...profile,
              fossil_extinct: $event.target.checked
            })"
          />
          Set all fossils as extinct
        </label>
        <div class="small_type">
          Automatically sets extinct on taxa whose name is classified as fossil.
          Per-taxon data attributes (controlled vocabulary) take precedence when present.
        </div>
      </div>

      <div class="field margin-medium-top">
        <label>Default environment</label>
        <select
          :value="profile.default_lifezone || ''"
          class="margin-small-top"
          @change="emit('update:profile', {
            ...profile,
            default_lifezone: $event.target.value || null
          })"
        >
          <option value="">
            None
          </option>
          <option value="brackish">
            Brackish
          </option>
          <option value="freshwater">
            Freshwater
          </option>
          <option value="marine">
            Marine
          </option>
          <option value="terrestrial">
            Terrestrial
          </option>
        </select>
        <div class="small_type">
          Applied to all taxa in the export. Per-taxon data attributes (controlled vocabulary) take precedence when present.
        </div>
      </div>

      <div class="field margin-medium-top">
        <label>Default download creator</label>
        <Autocomplete
          url="/users/autocomplete"
          label="label_html"
          min="2"
          placeholder="Select a user"
          param="term"
          :send-label="userLabel"
          @getItem="setDefaultUser"
        />
      </div>

      <div class="field margin-medium-top">
        <label>
          Max age (days)
          <input
            type="text"
            :value="profile.max_age"
            @input="emit('update:profile', {
              ...profile,
              max_age: $event.target.value ? Number($event.target.value) : null
            })"
            class="four_character_width margin-small-left"
          />
        </label>
        <div class="small_type">
          Suggested: 6 days for ChecklistBank usage
        </div>
      </div>

      <div
        v-if="publicUrl"
        class="field margin-medium-top"
      >
        <label>Public download URL</label>
        <div class="margin-small-top">
          <a
            :href="publicUrl"
            target="_blank"
          >{{ publicUrl }}</a>
        </div>
      </div>

      <VBtn
        @click="emit('save')"
        color="create"
        class="margin-medium-top"
      >
        Save profile
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import { getCurrentProjectId } from '@/helpers/project.js'
import { Otu, User, ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'

const projectId = Number(getCurrentProjectId())

const props = defineProps({
  profile: {
    type: Object,
    required: true
  },
  projectToken: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:profile', 'save'])

const otuLabel = ref('')
const userLabel = ref('')
const clbSearchQuery = ref('')
const clbResults = ref([])
const clbSearchOpen = ref(false)
const clbSelectedLabel = ref('')
let clbSearchTimeout = null

const publicUrl = computed(() => {
  if (!props.projectToken || !props.profile.otu_id || !props.profile.is_public) return null
  return `${window.location.origin}/api/v1/downloads/coldp_complete?project_token=${props.projectToken}&otu_id=${props.profile.otu_id}`
})

onMounted(() => {
  if (props.profile.otu_id) {
    fetchOtuLabel(props.profile.otu_id)
  }
  if (props.profile.default_user_id) {
    fetchUserLabel(props.profile.default_user_id)
  }
  if (props.profile.checklistbank_dataset_id) {
    fetchClbDatasetLabel(props.profile.checklistbank_dataset_id)
  }
})

watch(
  () => props.profile.otu_id,
  (newId, oldId) => {
    if (newId && newId !== oldId) {
      fetchOtuLabel(newId)
    } else if (!newId) {
      otuLabel.value = ''
    }
  }
)

async function fetchOtuLabel(otuId) {
  try {
    const { body } = await Otu.find(otuId)
    otuLabel.value = body.object_label || `OTU ${otuId}`
  } catch {
    otuLabel.value = `OTU ${otuId}`
  }
}

function setOtu(otu) {
  otuLabel.value = otu.label || `OTU ${otu.id}`
  emit('update:profile', { ...props.profile, otu_id: otu.id })
}



function setDefaultUser(user) {
  userLabel.value = user.label || `User ${user.id}`
  emit('update:profile', { ...props.profile, default_user_id: user.id })
}

async function fetchUserLabel(userId) {
  try {
    const { body } = await User.find(userId)
    userLabel.value = body.object_tag || body.name || `User ${userId}`
  } catch {
    userLabel.value = `User ${userId}`
  }
}

function clbDisplayLabel(dataset) {
  return [dataset.key || dataset, dataset.alias, dataset.title].filter(Boolean).join(' - ')
}

function onClbInput() {
  // If user starts typing over a selected dataset, clear the selection
  if (props.profile.checklistbank_dataset_id) {
    clbSelectedLabel.value = ''
    emit('update:profile', { ...props.profile, checklistbank_dataset_id: null })
  }

  clearTimeout(clbSearchTimeout)
  const query = clbSearchQuery.value.trim()

  if (query.length < 2) {
    clbResults.value = []
    clbSearchOpen.value = false
    return
  }

  clbSearchTimeout = setTimeout(async () => {
    try {
      const { body } = await ColdpExportPreference.searchDatasets(projectId, { q: query })
      clbResults.value = body || []
      clbSearchOpen.value = true
    } catch {
      clbResults.value = []
    }
  }, 300)
}

function onClbBackspace() {
  if (clbSearchQuery.value === '' && props.profile.checklistbank_dataset_id) {
    clbSelectedLabel.value = ''
    emit('update:profile', { ...props.profile, checklistbank_dataset_id: null })
  }
}

function selectClbDataset(dataset) {
  clbSelectedLabel.value = clbDisplayLabel(dataset)
  clbSearchQuery.value = clbSelectedLabel.value
  clbResults.value = []
  clbSearchOpen.value = false
  emit('update:profile', { ...props.profile, checklistbank_dataset_id: dataset.key })
}

function fetchClbDatasetLabel(datasetId) {
  ColdpExportPreference.searchDatasets(projectId, { q: String(datasetId) })
    .then(({ body }) => {
      const match = (body || []).find(d => d.key === datasetId)
      if (match) {
        clbSelectedLabel.value = clbDisplayLabel(match)
        clbSearchQuery.value = clbSelectedLabel.value
      } else {
        clbSearchQuery.value = String(datasetId)
      }
    })
    .catch(() => {
      clbSearchQuery.value = String(datasetId)
    })
}
</script>
