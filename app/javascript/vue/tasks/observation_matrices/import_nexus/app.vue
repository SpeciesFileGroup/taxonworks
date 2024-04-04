<template>
  <fieldset class="document_select">
    <legend>Select a Nexus document</legend>
    <SmartSelector
      klass="Documents"
      model="documents"
      v-model="nexusDoc"
      label="document_file_file_name"
    />
    <SmartSelectorItem
      :item="nexusDoc"
      label="document_file_file_name"
      @unset="() => nexusDoc = undefined"
    />
  </fieldset>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import { ref } from 'vue'

const nexusDoc = ref()
</script>

<style lang="scss" scoped>
.document_select {
  width: 600px;
  margin-top: 2em;
}
</style>
