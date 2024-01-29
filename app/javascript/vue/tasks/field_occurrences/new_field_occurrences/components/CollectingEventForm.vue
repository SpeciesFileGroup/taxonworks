<template>
  <BlockLayout :warning="!isFilled">
    <template #header>
      <h3>Collecting event</h3>
    </template>
    <template #options>
      <VIcon
        v-if="!isFilled"
        color="attention"
        name="attention"
        small
        title="You need to fill out this form in order to save"
      />
    </template>
    <template #body>
      <fieldset class="separate-bottom">
        <legend>Selector</legend>
        <div class="horizontal-left-content align-start separate-bottom">
          <SmartSelector
            class="full_width"
            ref="smartSelector"
            model="collecting_events"
            :target="FIELD_OCCURRENCE"
            :klass="FIELD_OCCURRENCE"
            pin-section="CollectingEvents"
            :pin-type="COLLECTING_EVENT"
            v-model="ceStore.collectingEvent"
            @selected="
              (ce) => {
                ceStore.load(ce.id)
              }
            "
          />
          <VLock
            class="margin-small-left"
            v-model="settings.locked.collectingEvent"
          />
        </div>
        <hr />
        <div class="horizontal-left-content middle gap-small">
          <VIcon
            color="attention"
            name="attention"
            small
          />
          <span v-if="ceStore.collectingEvent.id">
            Modifying existing ({{ ceStore.totalUsed }} uses)
          </span>
          <span v-else>New CE record.</span>
        </div>
        <div
          v-if="ceStore.collectingEvent.id"
          class="flex-separate middle"
        >
          <p v-html="ceStore.collectingEvent.object_tag" />
          <div class="horizontal-left-content">
            <div class="horizontal-left-content margin-small-right">
              <div
                v-if="ceStore.collectingEvent.id"
                class="horizontal-left-content margin-small-left gap-small"
              >
                <RadialAnnotator
                  :global-id="ceStore.collectingEvent.global_id"
                />
                <RadialObject :global-id="ceStore.collectingEvent.global_id" />
                <RadialNavigator
                  :global-id="ceStore.collectingEvent.global_id"
                />
                <VPin
                  :object-id="ceStore.collectingEvent.id"
                  type="CollectingEvent"
                />
                <VBtn
                  color="primary"
                  circle
                  @click="
                    () => {
                      ceStore.$reset()
                    }
                  "
                >
                  <VIcon
                    name="undo"
                    small
                  />
                </VBtn>
              </div>
            </div>
            <div class="horizontal-right-content gap-small">
              <VBtn
                color="create"
                @click="ceStore.clone()"
              >
                Clone
              </VBtn>
            </div>
          </div>
        </div>
      </fieldset>
      <FormCollectingEvent :exclude="[ComponentMap.PrintLabel]" />
    </template>
  </BlockLayout>
</template>

<script setup>
import RadialObject from '@/components/radials/object/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import FormCollectingEvent from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VPin from '@/components/ui/Pinboard/VPin.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import useCEStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useSettingStore from '../store/settings.js'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ComponentMap } from '@/components/Form/FormCollectingEvent/const/components.js'
import { COLLECTING_EVENT, FIELD_OCCURRENCE } from '@/constants'
import { computed } from 'vue'

const ceStore = useCEStore()
const settings = useSettingStore()

const isFilled = computed(
  () => ceStore.collectingEvent.id || ceStore.collectingEvent.isUnsaved
)
</script>
