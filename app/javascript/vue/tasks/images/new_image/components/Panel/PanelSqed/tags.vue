<template>
  <fieldset>
    <legend>Tags</legend>
    <smart-selector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Keyword' }"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      klass="Image"
      target="Image"
      @selected="(tag) => addToArray(tags, tag)"
    />
    <table-list
      v-if="tags.length"
      :list="tags"
      :header="['Tags', 'Remove']"
      :delete-warning="false"
      :annotator="false"
      :attributes="['object_tag']"
      @delete="(tag) => removeFromArray(tags, tag)"
    />
  </fieldset>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import TableList from '@/components/table_list'
import { MutationNames } from '../../../store/mutations/mutations'
import { GetterNames } from '../../../store/getters/getters'
import { computed } from 'vue'
import { useStore } from 'vuex'
import { removeFromArray, addToArray } from '@/helpers/arrays.js'

const store = useStore()

const tags = computed({
  get: () => store.getters[GetterNames.GetTags],

  set(value) {
    store.commit(MutationNames.SetTags, value)
  }
})
</script>
