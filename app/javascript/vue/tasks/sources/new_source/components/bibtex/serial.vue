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
          />
          <VLock
            class="margin-small-left"
            v-model="settings.lock.serial_id"
          />
          <a
            class="margin-small-top margin-small-left"
            target="_blank"
            href="/serials/new"
            >New</a
          >
        </div>
        <div
          class="middle separate-top"
          v-if="selected"
        >
          <div class="horizontal-left-content gap-small">
            <span v-html="selected.name" />
            <RadialObject :global-id="selected.global_id" />
            <VBtn
              color="primary"
              circle
              @click="unset"
            >
              <VIcon
                small
                name="undo"
              />
            </VBtn>
          </div>
        </div>
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
import VIcon from '@/components/ui/VIcon/index.vue'
import SmartSelector from '@/components/ui/SmartSelector'
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
