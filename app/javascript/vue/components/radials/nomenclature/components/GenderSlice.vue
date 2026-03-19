<template>
  <div>
    <VSpinner
      v-if="isProcessing"
      legend="Updating..."
    />

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
      <VBtn
        color="primary"
        :disabled="!canSubmit"
        @click="openModal"
      >
        {{ buttonLabel }}
      </VBtn>
    </div>

    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
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

const confirmationModalRef = ref(null)
const selectedMode = ref(null)
const selectedGender = ref(null)
const genderList = ref([])
const isProcessing = ref(false)

const canSubmit = computed(() => {
  if (!selectedMode.value) return false
  if (selectedMode.value === 'set') return !!selectedGender.value
  return true
})

const buttonLabel = computed(() => {
  if (selectedMode.value === 'remove_gender') return 'Remove gender'
  if (selectedMode.value === 'set' && selectedGender.value) {
    const g = genderList.value.find((item) => item.type === selectedGender.value)
    return g ? `Set ${g.name}` : 'Change gender'
  }
  return 'Set gender'
})

onMounted(() => {
  TaxonNameClassification.types().then(({ body }) => {
    const allTypes = body.latinized.all
    genderList.value = Object.values(allTypes)
      .filter((item) => GENDER_NAMES.includes(item.name))
      .sort(
        (a, b) => GENDER_NAMES.indexOf(a.name) - GENDER_NAMES.indexOf(b.name)
      )
  })
})

async function openModal() {
  const isRemove = selectedMode.value === 'remove_gender'
  const ok = await confirmationModalRef.value.show({
    title: 'Gender',
    message: `Are you sure you want to ${isRemove ? 'remove gender from' : 'set gender for'} all taxon names in the filter result?`,
    confirmationWord: isRemove ? 'REMOVE' : 'SET',
    okButton: buttonLabel.value,
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (!ok) return

  const payload = {
    filter_query: { [QUERY_PARAM[TAXON_NAME]]: props.parameters },
    mode: selectedMode.value,
    params: selectedMode.value === 'set' ? { type: selectedGender.value } : {}
  }

  isProcessing.value = true
  TaxonNameClassification.batchByFilter(payload)
    .then(({ body }) => {
      const count = body.async ? body.total_attempted : body.updated.length
      const message = body.async
        ? `${count} taxon names queued for gender update.`
        : isRemove
          ? `Gender removed from ${count} taxon names.`
          : `Gender updated for ${count} taxon names.`

      TW.workbench.alert.create(message, 'notice')
      emit('close')
    })
    .catch(() => {})
    .finally(() => {
      isProcessing.value = false
    })
}
</script>

<style scoped>
.capitalize {
  text-transform: capitalize;
}
</style>
