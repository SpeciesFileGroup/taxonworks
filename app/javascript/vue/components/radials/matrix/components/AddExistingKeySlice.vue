<template>
  <div>
    <VSpinner
      v-if="isLoading"
      legend="Loading"
    />
    <div>
      <div class="separate-bottom horizontal-left-content">
        <input
          v-model="inputType"
          type="text"
          placeholder="Filter keys"
        />
        <DefaultPin
          class="margin-small-left"
          section="Leads"
          type="Lead"
          @get-id="addToKey"
        />
      </div>
      <div class="flex-separate">
        <div>
          <div class="flex-wrap-column align-start gap-small">
            <template
              v-for="item in keysList"
              :key="item.id"
            >
              <VBtn
                medium
                color="create"
                v-html="item.object_tag"
                @click="() => addToKey(item.id)"
              />
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import DefaultPin from '@/components/ui/Button/ButtonPinned'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes'
import { Lead } from '@/routes/endpoints'
import { sortArray } from '@/helpers/arrays.js'
import { ref, computed, onBeforeMount } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const isLoading = ref(false)
const isSaving = ref(false)
const inputType = ref('')
const keys = ref([])

const keysList = computed(() =>
  keys.value.filter((item) =>
    item.object_tag.toLowerCase().includes(inputType.value.toLowerCase())
  )
)

function addToKey(keyId) {
  const payload = {
    ...props.parameters,
    lead_id: keyId
  }
console.log(props.parameters)
  isSaving.value = true
  Lead.batchAddLeadItems(keyId, payload)
    .then(({ body }) => {
      window.open(
        `${RouteNames.NewLead}?lead_id=${body.id}`,
        '_blank'
      )
      TW.workbench.alert.create(
        `Otus were successfully added.`,
        'notice'
      )
    })
    .catch(() => {})
    .finally(() => {
      isSaving.value = false
    })
}

onBeforeMount(() => {
  isLoading.value = true
  Lead.all({ per: 500 })
    .then(({ body }) => {
      keys.value = sortArray(body, 'object_tag')
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
})
</script>
