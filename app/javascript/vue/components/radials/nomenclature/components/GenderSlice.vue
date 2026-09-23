<template>
  <div>
    <fieldset>
      <legend>Action</legend>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              name="gender_mode"
              value="set"
              v-model="selectedMode"
            />
            Set gender
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              name="gender_mode"
              value="remove_gender"
              v-model="selectedMode"
            />
            Remove gender
          </label>
        </li>
      </ul>
    </fieldset>

    <fieldset v-if="selectedMode === 'set'">
      <legend>Gender</legend>
      <ul class="no_bullets">
        <li
          v-for="item in genderList"
          :key="item.type"
        >
          <label>
            <input
              type="radio"
              name="gender"
              :value="item.type"
              v-model="selectedGender"
            />
            <span class="capitalize">{{ item.name }}</span>
          </label>
        </li>
      </ul>
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        :batch-service="TaxonNameClassification.batchByFilter"
        :payload="payload"
        :disabled="!canSubmit"
        :button-label="buttonLabel"
        :confirmation-word="confirmationWord"
        @update="handleUpdateResult"
        @close="emit('close')"
      />
    </div>
  </div>
</template>

<script setup>
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { TaxonNameClassification } from '@/routes/endpoints'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { TAXON_NAME } from '@/constants'
import { ref, computed, onMounted } from 'vue'

const GENDER_NAMES = ['masculine', 'feminine', 'neuter']

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const selectedMode = ref(null)
const selectedGender = ref(null)
const genderList = ref([])

const isRemove = computed(() => selectedMode.value === 'remove_gender')

const canSubmit = computed(() => {
  if (!selectedMode.value) return false
  if (selectedMode.value === 'set') return !!selectedGender.value
  return true
})

const buttonLabel = computed(() => {
  if (isRemove.value) return 'Remove gender'
  if (selectedGender.value) {
    return `Set ${genderList.value.find((item) => item.type === selectedGender.value).name}`
  }
  return 'Set gender'
})

const confirmationWord = computed(() => (isRemove.value ? 'REMOVE' : 'SET'))

const payload = computed(() => ({
  filter_query: { [QUERY_PARAM[TAXON_NAME]]: props.parameters },
  mode: selectedMode.value,
  params: selectedMode.value === 'set' ? { type: selectedGender.value } : {}
}))

onMounted(() => {
  TaxonNameClassification.types()
    .then(({ body }) => {
      const allTypes = body.latinized.all
      genderList.value = Object.values(allTypes)
        .filter((item) => GENDER_NAMES.includes(item.name))
        .sort(
          (a, b) => GENDER_NAMES.indexOf(a.name) - GENDER_NAMES.indexOf(b.name)
        )
    })
    .catch(() => {})
})

function handleUpdateResult(data) {
  if (data.async) {
    TW.workbench.alert.create(
      `${data.total_attempted} taxon names queued for gender update.`,
      'notice'
    )
    return
  }

  const updatedCount = data.updated.length
  const notUpdatedCount = data.not_updated.length
  const action = isRemove.value ? 'removed from' : 'set for'

  if (updatedCount > 0 && notUpdatedCount === 0) {
    TW.workbench.alert.create(
      `Gender ${action} ${updatedCount} taxon names.`,
      'notice'
    )
  } else if (updatedCount > 0 && notUpdatedCount > 0) {
    TW.workbench.alert.create(
      `Gender ${action} ${updatedCount} taxon names, ${notUpdatedCount} not updated - see details below.`,
      'notice'
    )
  } else {
    TW.workbench.alert.create(
      `No taxon names updated (${notUpdatedCount} not updated) - see details below.`,
      'error'
    )
  }
}
</script>

<style scoped>
.capitalize {
  text-transform: capitalize;
}
</style>
