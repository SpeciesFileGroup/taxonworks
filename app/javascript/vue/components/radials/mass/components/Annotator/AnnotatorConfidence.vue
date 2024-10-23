<template>
  <div class="confidence_annotator">
    <h3>Mode</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in MODE"
        :key="key"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="selectedMode"
          />
          {{ key }}
        </label>
      </li>
    </ul>
    <div
      color="create"
      class="flex-wrap-row gap-small margin-large-top"
    >
      <VBtn
        v-for="item in list"
        :key="item.id"
        :color="selectedMode == MODE.Add ? 'create' : 'destroy'"
        medium
        @click="createConfidence(item)"
      >
        <span v-html="item.object_tag" />
      </VBtn>
    </div>

    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm, Confidence } from '@/routes/endpoints'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam.js'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../constants/confirmationOpts.js'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  }
})

const MODE = {
  Add: 'add',
  Remove: 'remove'
}

const confirmationModalRef = ref(null)
const list = ref([])

const selectedMode = ref(MODE.Add)

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: ['ConfidenceLevel'] }).then(
    ({ body }) => {
      list.value = body
    }
  )
})

async function createConfidence(confidence) {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    const idParam = ID_PARAM_FOR[props.objectType]
    const queryParam = QUERY_PARAM[props.objectType]
    const payload = {
      mode: selectedMode.value,
      confidence_level_id: confidence.id,
      filter_query: {
        [queryParam]: {
          ...props.parameters
        }
      }
    }

    if (props.ids?.length) {
      payload.filter_query[idParam] = props.ids
    }

    Confidence.batchByFilter(payload).then(() => {
      TW.workbench.alert.create(
        `Confidence item(s) were successfully ${
          selectedMode.value == MODE.Add ? 'created' : 'destroyed'
        }`,
        'notice'
      )
    })
  }
}
</script>
