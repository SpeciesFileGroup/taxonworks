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

    <span
      v-if="profiles.length > 0"
      class="reminder-bell"
      :class="{ 'reminder-bell--active': reminderEnabled }"
      :title="reminderEnabled
        ? 'COL publication reminder is ON — click to unsubscribe'
        : 'COL publication reminder is OFF — click to get notified 1 week before the monthly COL release'"
      @click="$emit('toggle-reminder')"
    >
      <!-- Filled bell (subscribed) -->
      <svg
        v-if="reminderEnabled"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        class="bell-icon"
      >
        <path
          fill-rule="evenodd"
          d="M5.25 9a6.75 6.75 0 0 1 13.5 0v.75c0 2.123.8 4.057 2.118 5.52a.75.75 0 0 1-.297 1.206c-1.544.57-3.16.99-4.831 1.243a3.75 3.75 0 1 1-7.48 0 24.585 24.585 0 0 1-4.831-1.244.75.75 0 0 1-.298-1.205A8.217 8.217 0 0 0 5.25 9.75V9Zm4.502 8.9a2.25 2.25 0 1 0 4.496 0 25.057 25.057 0 0 1-4.496 0Z"
          clip-rule="evenodd"
        />
      </svg>
      <!-- Outline bell (unsubscribed) -->
      <svg
        v-else
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="bell-icon"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0"
        />
      </svg>
    </span>
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
  },
  reminderEnabled: {
    type: Boolean,
    default: false
  }
})

defineEmits(['select', 'add', 'delete', 'toggle-reminder'])

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

.reminder-bell {
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  color: currentColor;
  opacity: 0.4;
  margin-left: auto;
  transition: opacity 0.15s;

  &:hover {
    opacity: 0.6;
  }

  &--active {
    color: currentColor;
    opacity: 1;

    &:hover {
      opacity: 0.8;
    }
  }
}

.bell-icon {
  width: 20px;
  height: 20px;
}
</style>
