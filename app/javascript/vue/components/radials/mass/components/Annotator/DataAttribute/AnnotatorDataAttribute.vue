<template>
  <div class="data_attribute_annotator">
    <DataAttributeUpdate
      v-if="nestedQuery"
      :parameters="parameters"
      :object-type="objectType"
      :controlled-vocabulary-terms="all"
      @create="emit('create')"
    />
    <DataAttributeCreate
      v-else
      :ids="ids"
      :object-type="objectType"
      :controlled-vocabulary-terms="all"
      @create="emit('create')"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import DataAttributeCreate from './DataAttributeCreate.vue'
import DataAttributeUpdate from './DataAttributeUpdate.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  },

  nestedQuery: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['create'])

const all = ref([])

ControlledVocabularyTerm.where({ type: ['Predicate'] }).then(({ body }) => {
  all.value = body
})
</script>
<style lang="scss">
.radial-annotator {
  .data_attribute_annotator {
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }

    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
