<template>
  <div>
    <VSpinner
      v-if="isUpdating"
      legend="Updating..."
    />
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>{{ count }} records will be updated</h3>

      <fieldset>
        <legend>Taxon name</legend>
        <SmartSelector
          model="taxon_names"
          :klass="TAXON_NAME"
          :target="TAXON_NAME"
          @selected="(item) => (taxon_name = item)"
        />
        <SmartSelectorItem
          :item="taxon_name"
          label="name"
          @unset="taxon_name = undefined"
        />
      </fieldset>

      <VBtn
        class="margin-large-top"
        color="create"
        medium
        :disabled="!taxon_name || isCountExceeded"
        @click="handleUpdate"
      >
        Update
      </VBtn>

      <ConfirmationModal ref="confirmationModalRef"/>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes.js'
import { Otu } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'
import { computed, ref } from 'vue'
import VSpinner from '@/components/spinner.vue'

const MAX_LIMIT = 250

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const taxon_name = ref()
const confirmationModalRef = ref(null)
const isUpdating = ref(false)

const isCountExceeded = computed(() => props.count > MAX_LIMIT)


function changeTaxonName() {
  const payload = {
    otu_query: props.parameters,
    otu: {
      taxon_name_id: taxon_name.value.id
    },
  }

  isUpdating.value = true

  Otu.batchUpdate(payload).then(({ body }) => {
    let message
    if (body['queued'] === true) {
      message = `${body.total} OTUs queued for updating.`
    } else {
      message = `${body.passed.length} OTUs were successfully updated.`
    }
    TW.workbench.alert.create(
      message,
      'notice'
    )

    isUpdating.value = false
  })
}


async function handleUpdate() {
  const ok =
    (await confirmationModalRef.value.show({
      title: 'Change taxon name ',
      message:
        'This will change the taxon name for the selected OTUs. Are you sure you want to proceed?',
      confirmationWord: 'CHANGE',
      okButton: 'Update',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    }))

  if (ok) {
    changeTaxonName()
  }
}
</script>
