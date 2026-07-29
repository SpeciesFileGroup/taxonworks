<template>
  <div class="field label-above">
    <label>Translated from serial</label>
    <div class="horizontal-left-content gap-small">
      <VAutocomplete
        url="/serials/autocomplete"
        param="term"
        label="label_html"
        display="label"
        placeholder="Select a serial"
        :excluded-ids="excludedIds"
        :send-label="serialLabel"
        @get-item="setSerial"
      />
      <VBtn
        v-if="translatedFromSerialId"
        color="primary"
        icon
        variant="tonal"
        title="Remove serial"
        @click="unset"
      >
        <IconReset class="w-4 h-4" />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Serial } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconReset from '@/components/Icon/IconReset.vue'

const props = defineProps({
  // Id of the serial being edited, it can not be a translation of itself
  excludeId: {
    type: Number,
    default: undefined
  }
})

const translatedFromSerialId = defineModel({
  type: Number,
  default: undefined
})

const serialLabel = ref('')
const excludedIds = computed(() => (props.excludeId ? [props.excludeId] : []))

watch(
  translatedFromSerialId,
  (newVal) => {
    if (!newVal) {
      serialLabel.value = ''
      return
    }

    Serial.find(newVal).then(({ body }) => {
      serialLabel.value = body.name
    })
  },
  { immediate: true }
)

function setSerial({ id, label }) {
  serialLabel.value = label
  translatedFromSerialId.value = id
}

function unset() {
  serialLabel.value = ''
  translatedFromSerialId.value = undefined
}
</script>
