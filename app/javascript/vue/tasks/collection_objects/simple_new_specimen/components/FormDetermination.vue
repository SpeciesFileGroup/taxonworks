<template>
  <div class="panel content">
    <h2>Determination</h2>
    <fieldset>
      <legend>OTU</legend>
      <SmartSelector
        model="otus"
        :target="TAXON_DETERMINATION"
        :klass="TAXON_DETERMINATION"
        @get-item="setOtu"
      >
        <template #tabs-right>
          <VLock
            class="margin-small-left"
            v-model="store.settings.lock.determination"
          />
        </template>
      </SmartSelector>
    </fieldset>
  </div>
</template>

<script setup>
import { TAXON_DETERMINATION } from 'constants/index'
import { useStore } from '../store/useStore'
import SmartSelector from 'components/ui/SmartSelector.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()

function setOtu (value) {
  store.otu = value
}

</script>
