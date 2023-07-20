<template>
  <BlockLayout>
    <template #header>
      <h3>Source</h3>
    </template>
    <template #body>
      <smart-selector
        class="separate-bottom"
        model="sources"
        klass="Depiction"
        label="cached"
        v-model="source"
        @selected="($event) => (source = $event)"
      />
      <SmartSelectorItem
        :item="source"
        label="cached"
        @unset="source = undefined"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { computed } from 'vue'
import { useStore } from 'vuex'

const store = useStore()

const source = computed({
  get: () => store.getters[GetterNames.GetSource],
  set(value) {
    store.commit(MutationNames.SetSource, value)
  }
})
</script>
