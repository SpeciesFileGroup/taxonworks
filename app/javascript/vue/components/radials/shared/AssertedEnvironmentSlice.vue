<template>
  <div>
    <fieldset>
      <legend>Action</legend>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              name="asserted_environment_mode"
              value="add"
              v-model="selectedMode"
            />
            Add asserted environment
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              name="asserted_environment_mode"
              value="remove"
              v-model="selectedMode"
            />
            Remove asserted environment
          </label>
        </li>
      </ul>
    </fieldset>

    <fieldset class="margin-medium-top">
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
      v-if="!isRemove"
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
        :confirmation-word="confirmationWord"
        :button-label="buttonLabel"
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

const selectedMode = ref('add')
const environment = ref()
const citation = ref({
  source_id: undefined,
  pages: undefined,
  is_original: undefined
})

const isRemove = computed(() => selectedMode.value === 'remove')

const buttonLabel = computed(() => (isRemove.value ? 'Remove' : 'Create'))

const confirmationWord = computed(() => (isRemove.value ? 'REMOVE' : 'CREATE'))

const payload = computed(() => ({
  filter_query: { [QUERY_PARAM[props.objectType]]: props.parameters },
  mode: selectedMode.value,
  params: {
    uri: environment.value?.uri,
    uri_label: environment.value?.uri_label,
    citation:
      !isRemove.value && citation.value.source_id
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
      `${data.total_attempted} records queued for asserted environment ${isRemove.value ? 'removal' : 'creation'}.`,
      'notice'
    )
    return
  }

  const updatedCount = data.updated.length
  const notUpdatedCount = data.not_updated.length
  const action = isRemove.value ? 'removed' : 'created or cited'

  if (notUpdatedCount === 0) {
    TW.workbench.alert.create(
      `${updatedCount} asserted environments were successfully ${action}.`,
      'notice'
    )
  } else {
    TW.workbench.alert.create(
      `${updatedCount} asserted environments ${action}, ${notUpdatedCount} records not updated.`,
      updatedCount > 0 ? 'notice' : 'error'
    )
  }
}
</script>
