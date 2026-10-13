<template>
  <div>
    <h3>New asserted environment</h3>

    <fieldset>
      <legend>Environment</legend>
      <AutoselectField
        url="/asserted_environments/autoselect"
        param="uri"
        placeholder="Search ENVO, or terms already used in this project"
        reset-on-select
        @select="setEnvironment"
      />
      <SmartSelectorItem
        label="uri_label"
        :item="environment"
        @unset="() => (environment = undefined)"
      />
    </fieldset>

    <FormCitation
      class="margin-medium-top"
      v-model="citation"
      :klass="ASSERTED_ENVIRONMENT"
      :target="ASSERTED_ENVIRONMENT"
      use-session
    />

    <div class="horizontal-left-content gap-small margin-medium-top">
      <UpdateBatch
        :batch-service="AssertedEnvironment.batchByFilter"
        :payload="payload"
        :disabled="!environment"
        confirmation-word="CREATE"
        button-label="Create"
        @update="updateMessage"
        @close="emit('close')"
      />
    </div>
  </div>
</template>

<script setup>
// # Claude: provided >50% of this component
import { ref, computed } from 'vue'
import { ASSERTED_ENVIRONMENT } from '@/constants/index'
import { AssertedEnvironment } from '@/routes/endpoints'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['close'])

const environment = ref()
const citation = ref({
  source_id: undefined,
  pages: undefined,
  is_original: undefined
})

const payload = computed(() => ({
  filter_query: { [QUERY_PARAM[props.objectType]]: props.parameters },
  mode: 'add',
  params: {
    uri: environment.value?.uri,
    uri_label: environment.value?.uri_label,
    citation: citation.value.source_id
      ? {
          source_id: citation.value.source_id,
          pages: citation.value.pages,
          is_original: citation.value.is_original
        }
      : undefined
  }
}))

function setEnvironment(item) {
  const { uri, uri_label } = item.response_values

  environment.value = { uri, uri_label }
}

function updateMessage(data) {
  if (data.async) {
    TW.workbench.alert.create(
      `${data.total_attempted} asserted environments queued for creation.`,
      'notice'
    )
    return
  }

  const updatedCount = data.updated.length
  const notUpdatedCount = data.not_updated.length

  if (notUpdatedCount === 0) {
    TW.workbench.alert.create(
      `${updatedCount} asserted environments were successfully created or cited.`,
      'notice'
    )
  } else {
    TW.workbench.alert.create(
      `${updatedCount} asserted environments created or cited, ${notUpdatedCount} records not updated.`,
      updatedCount > 0 ? 'notice' : 'error'
    )
  }
}
</script>
