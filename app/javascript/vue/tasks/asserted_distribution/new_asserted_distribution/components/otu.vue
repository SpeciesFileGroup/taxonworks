<template>
  <fieldset>
    <legend>Otu</legend>
    <div class="horizontal-left-content align-start">
      <smart-selector
        v-model="otu"
        class="full_width"
        model="otus"
        klass="AssertedDistribution"
        target="AssertedDistribution"
        pin-section="Otus"
        pin-type="Otu"
        search
        :autocomplete="false"
        otu-picker
      />
      <VLock
        v-model="lock"
        class="margin-small-left"
      />
    </div>
    <SmartSelectorItem
      :item="otu"
      label="object_tag"
      @unset="otu = undefined"
    />
  </fieldset>
</template>

<script setup>
import { computed } from 'vue'
import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VLock from 'components/ui/VLock/index.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  lock: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'update:modelValue',
  'update:lock'
])

const otu = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const lock = computed({
  get: () => props.lock,
  set: value => emit('update:lock', value)
})

</script>

<style scoped>
  li {
    margin-bottom: 8px;
  }
</style>
