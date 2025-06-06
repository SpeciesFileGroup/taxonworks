<template>
  <div class="data_attribute_annotator">
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      :custom-list="{ all: controlledVocabularyTerms }"
      @selected="
        (item) => {
          predicate = item
        }
      "
    />
    <SmartSelectorItem
      :item="predicate"
      label="name"
      @unset="
        () => {
          predicate = null
        }
      "
    />

    <textarea
      v-model="predicateValue1"
      class="separate-bottom"
      :placeholder="textBox1Default"
    />

    <textarea
      v-if="textBox2Default"
      v-model="predicateValue2"
      class="separate-bottom"
      :placeholder="textBox2Default"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  controlledVocabularyTerms: {
    type: Array,
    default: () => []
  },

  textBox1Default: {
    type: String,
    default: ''
  },

  textBox2Default: {
    type: String,
    default: ''
  }
})

const predicate = defineModel('predicate', {
  type: Object,
  default: () => ({})
})

const predicateValue1 = defineModel('predicateValue1', {
  type: String,
  default: ''
})

const predicateValue2 = defineModel('predicateValue2', {
  type: String,
  default: ''
})

</script>

<style lang="scss">

</style>
