<template>
  <div class="panel padding-medium profile-selector">
    <span>Profile:</span>
    <select
      :value="selectedIndex"
      @change="$emit('select', Number($event.target.value))"
    >
      <option
        v-for="(profile, index) in profiles"
        :key="index"
        :value="index"
      >
        {{ profileLabel(profile, index) }}
      </option>
    </select>

    <VBtn
      color="primary"
      @click="$emit('add')"
    >
      New
    </VBtn>

    <VBtn
      v-if="profiles.length > 0"
      color="destroy"
      @click="$emit('delete')"
    >
      Delete
    </VBtn>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Otu } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  profiles: {
    type: Array,
    required: true
  },
  selectedIndex: {
    type: Number,
    required: true
  }
})

defineEmits(['select', 'add', 'delete'])

const otuLabels = ref({})

watch(
  () => props.profiles,
  (newProfiles) => {
    newProfiles.forEach((profile) => {
      if (profile.otu_id && !otuLabels.value[profile.otu_id]) {
        fetchOtuLabel(profile.otu_id)
      }
    })
  },
  { immediate: true }
)

async function fetchOtuLabel(otuId) {
  try {
    const { body } = await Otu.find(otuId)
    otuLabels.value[otuId] = body.object_label || `OTU ${otuId}`
  } catch {
    otuLabels.value[otuId] = `OTU ${otuId}`
  }
}

function profileLabel(profile, index) {
  if (profile.otu_id) {
    const label = otuLabels.value[profile.otu_id] || `OTU ${profile.otu_id}`
    return profile.checklistbank_dataset_id
      ? `${label} (CLB: ${profile.checklistbank_dataset_id})`
      : label
  }
  return `New profile ${index + 1}`
}
</script>

<style lang="scss" scoped>
.profile-selector {
  display: flex;
  flex-direction: row;
  align-items: center;
  flex-wrap: nowrap;
  gap: 0.5em;
}
</style>
