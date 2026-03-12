<template>
  <div>
    <p>
      <i>Only assigns gender to genera that don't already have one.</i>
    </p>
    <fieldset>
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
        ref="updateBatchRef"
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!selectedGender"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!selectedGender"
        @finalize="
          () => {
            updateBatchRef.openModal()
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { TaxonName, TaxonNameClassification } from '@/routes/endpoints'
import { ref, computed, onMounted } from 'vue'

const GENDER_NAMES = ['masculine', 'feminine', 'neuter']

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const selectedGender = ref(null)
const genderList = ref([])

const payload = computed(() => ({
  taxon_name_query: props.parameters,
  taxon_name: {
    taxon_name_classifications_attributes: [
      { type: selectedGender.value }
    ]
  }
}))

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

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} taxon names queued for updating.`
    : `${data.updated.length} taxon names were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>

<style scoped>
.capitalize {
  text-transform: capitalize;
}
</style>
