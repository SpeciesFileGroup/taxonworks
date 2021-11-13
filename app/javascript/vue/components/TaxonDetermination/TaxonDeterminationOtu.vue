<template>
  <fieldset
    class="separate-bottom">
    <legend>OTU</legend>
    <div class="horizontal-left-content separate-bottom align-start">
      <smart-selector
        class="margin-medium-bottom full_width"
        model="otus"
        ref="smartSelector"
        pin-section="Otus"
        pin-type="Otu"
        :autocomplete="false"
        :otu-picker="true"
        target="TaxonDetermination"
        v-model="otu"
      />
    </div>
    <div
      v-if="otu"
      class="horizontal-left-content">
      <p v-html="otu.object_tag"/>
      <span
        class="circle-button button-default btn-undo"
        @click="otu = undefined"/>
    </div>
  </fieldset>
</template>

<script setup>

import { computed } from 'vue'
import SmartSelector from 'components/ui/SmartSelector.vue'

const props = defineProps({
  modelValue: Object
})

const emit = defineEmits(['update:modelValue'])
const otu = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

</script>
