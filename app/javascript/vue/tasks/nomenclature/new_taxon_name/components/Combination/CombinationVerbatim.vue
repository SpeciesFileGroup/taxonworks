<template>
  <div class="horizontal-left-content">
    <edit-in-place
      legend="Click to edit verbatim"
      v-model="verbatimName"/>
    <tippy
      v-if="verbatimName"
      animation="scale"
      placement="bottom"
      size="small"
      inertia
      arrow
      content="Verbatim representations are for display purposes only, only use them as a last resort. Legitimate reasons may include gender agreement errors. You should likely create a new name and treat it as a misspelling or low level synonym. Creating a new name gives you more power and flexibility in downstream search and display. Do NOT use this to include comon, or temporary names whose use was not intended to be governed by a code of nomenclature">
      <v-icon
        class="margin-small-left"
        name="attention"
        color="attention"
        small
      />
    </tippy>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { Tippy } from 'vue-tippy'
import VIcon from 'components/ui/VIcon/index.vue'
import EditInPlace from 'components/editInPlace.vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})
const emit = defineEmits(['update:modelValue'])
const verbatimName = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
