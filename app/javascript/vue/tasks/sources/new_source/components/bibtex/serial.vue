<template>
  <div>
    <div class="horizontal-left-content full_width">
      <fieldset
        v-help.section.BibTeX.serial
        class="full_width"
      >
        <legend>Serial</legend>
        <div class="horizontal-left-content align-start">
          <SmartSelector
            class="full_width"
            input-id="serials-autocomplete"
            model="serials"
            target="Source"
            klass="Source"
            label="name"
            pin-section="Serials"
            pin-type="Serial"
            :filter-ids="selected ? [selected.id] : []"
            @selected="setSelected"
          >
            <template #tabs-right>
              <div class="w-full flex-separate">
                <WidgetSerial @create="setSelected">
                  <template #default="{ open }">
                    <VBtn
                      color="primary"
                      icon
                      variant="tonal"
                      title="New serial"
                      medium
                      @click="open"
                    >
                      <IconPlus class="w-4 h-4" />
                    </VBtn>
                  </template>
                </WidgetSerial>
                <VLock
                  class="margin-small-left"
                  v-model="settings.lock.serial_id"
                />
              </div>
            </template>
          </SmartSelector>
        </div>
        <SmartSelectorItem
          class="separate-top"
          :item="selected"
          label="name"
          @unset="unset"
        >
          <template #options-left>
            <RadialObject :global-id="selected.global_id" />
          </template>
        </SmartSelectorItem>
      </fieldset>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useSettingStore } from '../../store'
import { Serial } from '@/routes/endpoints'
import VLock from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPlus from '@/components/Icon/IconPlus.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import WidgetSerial from '@/components/ui/Widget/WidgetSerial.vue'
import RadialObject from '@/components/radials/navigation/radial'

const source = defineModel({
  type: Object,
  required: true
})

const settings = useSettingStore()
const selected = ref()

watch(
  () => source.value.serial_id,
  (newVal, oldVal) => {
    if (newVal) {
      if (oldVal !== newVal) {
        Serial.find(newVal).then(({ body }) => {
          selected.value = body
        })
      }
    } else {
      selected.value = undefined
    }
  },
  {
    immediate: true,
    deep: true
  }
)

function setSelected(serial) {
  selected.value = serial
  source.value.serial_id = serial.id
  source.value.isUnsaved = true
}

function unset() {
  selected.value = undefined
  source.value.serial_id = null
  source.value.isUnsaved = true
}
</script>
