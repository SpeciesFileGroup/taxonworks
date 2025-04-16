<template>
  <div>
    <VSpinner v-if="isSaving" />
    <div class="field label-above">
      <input
        type="text"
        class="full_width"
        placeholder="Type a key name... "
        v-model="keyName"
      />
    </div>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!keyName"
      @click="addToLead"
    >
      Create
    </VBtn>

    <div
      v-if="created"
      class="margin-medium-top"
    >
      <h3>Created</h3>
      Edit
      <a :href="`${RouteNames.NewLead}?lead_id=${created.id}`">
        {{ created.text }}
      </a>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { RouteNames } from '@/routes/routes'
import { Lead} from '@/routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const keyName = ref('')
const created = ref(undefined)
const isSaving = ref(false)

function addToLead() {
  const payload = {
    ...props.parameters,
    lead: {
      text: keyName.value
    }
  }

  isSaving.value = true

  Lead.batch_create(payload)
    .then(({ body }) => {
      created.value = body
      TW.workbench.alert.create(
        `New key was successfully created.`,
        'notice'
      )
      keyName.value = ''
      created.value = body
    })
    .finally(() => {
      isSaving.value = false
    })
}
</script>
