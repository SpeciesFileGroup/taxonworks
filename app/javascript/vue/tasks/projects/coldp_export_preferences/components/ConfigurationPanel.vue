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
        <label>ChecklistBank Dataset ID</label>
        <input
          type="number"
          :value="profile.checklistbank_dataset_id"
          @input="emit('update:profile', {
            ...profile,
            checklistbank_dataset_id: $event.target.value ? Number($event.target.value) : null
          })"
          class="clb-dataset-id-input margin-small-top"
        />
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
import { Otu } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'

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

const publicUrl = computed(() => {
  if (!props.projectToken || !props.profile.otu_id || !props.profile.is_public) return null
  return `${window.location.origin}/api/v1/downloads/coldp_complete?project_token=${props.projectToken}&otu_id=${props.profile.otu_id}`
})

onMounted(() => {
  if (props.profile.otu_id) {
    fetchOtuLabel(props.profile.otu_id)
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
</script>

<style lang="scss" scoped>
.text-number-input {
  width: 5em;
}

.clb-dataset-id-input {
  display: block;
  width: 16em;
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
