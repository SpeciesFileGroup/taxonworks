<template>
  <BlockLayout>
    <template #header>
      <h3>Tags</h3>
    </template>
    <template #body>
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
        class="margin-medium-top"
        :list="tags"
        :header="['Tags', 'Remove']"
        :delete-warning="false"
        :annotator="false"
        :attributes="['object_tag']"
        @delete="(tag) => removeFromArray(tags, tag)"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import TableList from '@/components/table_list'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { computed } from 'vue'
import { useStore } from 'vuex'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { addToArray, removeFromArray } from '@/helpers/arrays'

const store = useStore()

const tags = computed({
  get() {
    return store.getters[GetterNames.GetTagsForImage]
  },
  set(value) {
    store.commit(MutationNames.SetTagsForImage, value)
  }
})
</script>
