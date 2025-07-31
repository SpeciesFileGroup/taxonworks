<template>
  <BlockLayout>
    <template #header>
      <h3>Confidences</h3>
    </template>
    <template #body>
      <div class="margin-small-bottom horizontal-left-content align-start">
        <SmartSelector
          class="full_width"
          ref="smartSelectorRef"
          autocomplete-url="/controlled_vocabulary_terms/autocomplete"
          :autocomplete-params="{ 'type[]': CONFIDENCE_LEVEL }"
          get-url="/controlled_vocabulary_terms/"
          model="confidence_levels"
          klass="Confidence"
          pin-section="ConfidenceLevels"
          :pin-type="CONFIDENCE_LEVEL"
          :add-tabs="['all']"
          :target="EXTRACT"
          @selected="addConfidence"
        >
          <template #tabs-right>
            <VLock
              class="margin-small-left"
              v-model="settings.lock.confidences"
            />
          </template>
          <template #all>
            <VModal @close="smartSelectorRef.setTab('quick')">
              <template #header>
                <h3>Confidence levels - all</h3>
              </template>
              <template #body>
                <VBtn
                  v-for="item in allList"
                  :key="item.id"
                  class="margin-small-bottom margin-small-right"
                  color="primary"
                  pill
                  @click="() => addConfidence(item)"
                >
                  {{ item.name }}
                </VBtn>
              </template>
            </VModal>
          </template>
        </SmartSelector>
      </div>
      <table
        v-if="confidences.length"
        class="table-striped full_width"
      >
        <thead>
          <tr>
            <th>Confidence</th>
            <th class="w-2" />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in confidences"
            :key="item.confidenceLevelId"
          >
            <td v-html="item.label" />
            <td>
              <VBtn
                circle
                :color="item.id ? 'destroy' : 'primary'"
                @click="() => removeConfidence(item)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </BlockLayout>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { CONFIDENCE_LEVEL, EXTRACT } from '@/constants'

import SmartSelector from '@/components/ui/SmartSelector'
import VLock from '@/components/ui/VLock/index.vue'
import BlockLayout from '@/components/layout/BlockLayout'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ActionNames from '../store/actions/actionNames'
import VModal from '@/components/ui/Modal.vue'

const store = useStore()
const smartSelectorRef = ref()
const allList = ref()

const confidences = computed({
  get() {
    return store.getters[GetterNames.GetConfidences]
  },
  set(value) {
    store.commit(MutationNames.SetConfidences, value)
  }
})

const settings = computed({
  get: () => store.getters[GetterNames.GetSettings],
  set: (value) => store.commit(MutationNames.SetSettings, value)
})

ControlledVocabularyTerm.where({ type: [CONFIDENCE_LEVEL] }).then(
  ({ body }) => {
    allList.value = body
  }
)

function addConfidence(item) {
  store.commit(MutationNames.AddConfidence, {
    confidence_level_id: item.id,
    name: item.object_tag,
    isUnsaved: true
  })
}

function removeConfidence(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    store.dispatch(ActionNames.RemoveConfidence, item)
  }
}
</script>
