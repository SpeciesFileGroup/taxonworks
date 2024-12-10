<template>
  <BlockLayout>
    <template #header>
      <h3>Predicate</h3>
    </template>
    <template #body>
      <SmartSelector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{ 'type[]': PREDICATE }"
        get-url="/controlled_vocabulary_terms/"
        model="predicates"
        buttons
        inline
        :klass="objectType"
        :custom-list="{ all }"
        :lock-view="false"
        :filter-ids="store.predicates.map((item) => item.id)"
        @selected="addPredicate"
      />
      <VSpinner
        v-if="isLoading"
        full-screen
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { PREDICATE } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useStore from '../store/store.js'

defineProps({
  objectType: {
    type: String,
    default: 'CollectionObject'
  }
})

const all = ref([])
const store = useStore()
const isLoading = ref(false)

ControlledVocabularyTerm.where({ type: [PREDICATE] }).then(({ body }) => {
  all.value = body
})

function addPredicate(predicate) {
  store.addPredicate(predicate)

  isLoading.value = true
  store.loadDataAttributes(predicate.id).finally(() => {
    isLoading.value = false
  })
}
</script>
