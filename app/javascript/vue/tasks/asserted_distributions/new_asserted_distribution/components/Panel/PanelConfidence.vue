<template>
  <BlockLayout>
    <template #header>
      <div class="flex-row flex-separate full_width middle">
        <h3>Confidence</h3>
        <div v-if="store.autosave">
          <div class="flex-row gap-small middle">
            <VIcon
              name="attention"
              color="attention"
              small
            />
            <span class="text-warning-color">
              Autosave is enabled. Complete this section first to add confidence
              levels
            </span>
          </div>
        </div>
      </div>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <SmartSelector
          class="full_width"
          autocomplete-url="/controlled_vocabulary_terms/autocomplete"
          :autocomplete-params="{ 'type[]': CONFIDENCE_LEVEL }"
          get-url="/controlled_vocabulary_terms/"
          model="confidence_levels"
          :klass="TAG"
          :target="ASSERTED_DISTRIBUTION"
          :custom-list="{ all: allList }"
          :filter="
            (item) =>
              !store.confidences.some(
                (i) => i.controlledVocabularyId === item.id
              )
          "
          @selected="
            (item) =>
              addToArray(
                store.confidences,
                {
                  controlledVocabularyId: item.id,
                  label: item.object_tag
                },
                { property: 'controlledVocabularyId' }
              )
          "
        >
          <template #tabs-right>
            <VLock v-model="store.lock.confidences" />
          </template>
        </SmartSelector>
      </div>

      <div v-if="store.confidences.length">
        <hr class="divisor" />
        <table class="full_width table-striped">
          <thead>
            <tr>
              <th>Selected</th>
              <th class="w-2" />
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in store.confidences"
              :key="item.controlledVocabularyId"
            >
              <td v-html="item.label" />
              <td>
                <VBtn
                  color="primary"
                  circle
                  @click="() => store.confidences.splice(index, 1)"
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
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { CONFIDENCE_LEVEL, TAG, ASSERTED_DISTRIBUTION } from '@/constants'
import { addToArray } from '@/helpers'
import { useStore } from '../../store/store'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VLock from '@/components/ui/VLock/index.vue'

const allList = ref([])
const store = useStore()

ControlledVocabularyTerm.where({ type: [CONFIDENCE_LEVEL] }).then(
  ({ body }) => {
    allList.value = body
  }
)
</script>
