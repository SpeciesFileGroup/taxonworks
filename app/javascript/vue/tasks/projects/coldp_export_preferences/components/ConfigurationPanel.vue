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
        <div class="clb-search-wrapper margin-small-top">
          <input
            type="text"
            v-model="clbSearchQuery"
            placeholder="Search ChecklistBank datasets..."
            class="clb-search-input"
            @input="searchClbDatasets"
          />
          <ul
            v-if="clbResults.length > 0 && clbSearchOpen"
            class="clb-results"
          >
            <li
              v-for="dataset in clbResults"
              :key="dataset.key"
              @click="selectClbDataset(dataset)"
            >
              <span class="clb-result-key">{{ dataset.key }}</span>
              <span
                v-if="dataset.alias"
                class="clb-result-alias"
              >{{ dataset.alias }}</span>
              <span class="clb-result-title">{{ dataset.title }}</span>
            </li>
          </ul>
        </div>
        <div
          v-if="profile.checklistbank_dataset_id"
          class="clb-selected margin-small-top"
        >
          Selected: <b>{{ profile.checklistbank_dataset_id }}</b>
          <span v-if="clbSelectedLabel"> - {{ clbSelectedLabel }}</span>
          <a
            href="#"
            class="margin-small-left"
            @click.prevent="clearClbDataset"
          >clear</a>
        </div>
      </div>

      <div class="field margin-medium-top">
        <label>Base URL for taxon links</label>
        <input
          type="text"
          :value="profile.base_url"
          @input="emit('update:profile', {
            ...profile,
            base_url: $event.target.value
          })"
          placeholder="e.g. https://hoppers.speciesfile.org/otus/{otu_id}/overview"
          class="base-url-input margin-small-top"
        />
        <div class="help-text">
          Use <code>{otu_id}</code> as placeholder for the OTU ID
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
        <div class="help-text">
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
        <div class="help-text">
          Applied to all taxa in the export. Per-taxon data attributes (controlled vocabulary) take precedence when present.
        </div>
      </div>

      <div class="field margin-medium-top">
        <label>Default download creator</label>
        <div class="user-select">
          <Autocomplete
            url="/users/autocomplete"
            label="label_html"
            min="2"
            placeholder="Select a user"
            param="term"
            clear-after
            @getItem="setDefaultUser"
          />
          <span v-if="profile.default_user_id">
            User ID: {{ profile.default_user_id }}
          </span>
        </div>
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
            class="text-number-input margin-small-left"
          />
        </label>
        <div class="help-text">
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
import { Otu, ColdpExportPreference } from '@/routes/endpoints'
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
  emit('update:profile', { ...props.profile, default_user_id: user.id })
}

function searchClbDatasets() {
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

function selectClbDataset(dataset) {
  clbSelectedLabel.value = [dataset.alias, dataset.title].filter(Boolean).join(' - ')
  clbSearchQuery.value = ''
  clbResults.value = []
  clbSearchOpen.value = false
  emit('update:profile', { ...props.profile, checklistbank_dataset_id: dataset.key })
}

function clearClbDataset() {
  clbSelectedLabel.value = ''
  emit('update:profile', { ...props.profile, checklistbank_dataset_id: null })
}

function fetchClbDatasetLabel(datasetId) {
  ColdpExportPreference.searchDatasets(projectId, { q: String(datasetId) })
    .then(({ body }) => {
      const match = (body || []).find(d => d.key === datasetId)
      if (match) {
        clbSelectedLabel.value = [match.alias, match.title].filter(Boolean).join(' - ')
      }
    })
    .catch(() => {})
}
</script>

<style lang="scss" scoped>
.text-number-input {
  width: 5em;
}

.clb-search-wrapper {
  position: relative;
}

.clb-search-input {
  display: block;
  width: 100%;
  box-sizing: border-box;
}

.clb-results {
  position: absolute;
  z-index: 10;
  list-style: none;
  margin: 0;
  padding: 0;
  background: var(--bg-color, white);
  border: 1px solid var(--border-color, #ccc);
  border-top: none;
  max-height: 250px;
  overflow-y: auto;
  width: 100%;
  box-sizing: border-box;

  li {
    padding: 0.4em 0.6em;
    cursor: pointer;
    display: flex;
    gap: 0.5em;
    align-items: baseline;

    &:hover {
      background-color: var(--bg-muted, #f0f0f0);
    }
  }
}

.clb-result-key {
  font-weight: 600;
  white-space: nowrap;
}

.clb-result-alias {
  opacity: 0.7;
  white-space: nowrap;
}

.clb-result-title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.clb-selected {
  font-size: 0.9em;
}

.base-url-input {
  display: block;
  width: 100%;
  box-sizing: border-box;
}

.user-select {
  width: 400px;
}

.help-text {
  font-size: 0.9em;
  opacity: 0.7;
}
</style>
