<template>
  <div class="panel content">
    <h2>Determination</h2>
    <fieldset>
      <legend>OTU</legend>
      <SmartSelector
        model="otus"
        :target="TAXON_DETERMINATION"
        :klass="TAXON_DETERMINATION"
        v-model="store.otu"
      >
        <template #tabs-right>
          <VLock
            class="margin-small-left"
            v-model="store.settings.lock.otu"
          />
        </template>
      </SmartSelector>
      <hr v-if="store.otu">
      <SmartSelectorItem
        :item="store.otu"
        @unset="store.otu = undefined"
      />
    </fieldset>
  </div>
</template>

<script setup>
import { TAXON_DETERMINATION } from 'constants/index'
import { useStore } from '../store/useStore'
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()

</script>
