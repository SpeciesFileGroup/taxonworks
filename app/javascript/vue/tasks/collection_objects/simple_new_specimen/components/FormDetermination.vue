<template>
  <div>
    <label>OTU</label>
    <div class="horizontal-left-content middle field">
      <SelectedItem
        v-if="store.otu"
        class="full_width"
        :item="store.otu"
        @unset="store.otu = undefined"
      />
      <Autocomplete
        v-else
        class="full_width"
        url="/otus/autocomplete"
        placeholder="Search an OTU"
        label="label_html"
        display="label"
        param="term"
        @get-item="store.otu = $event"
      />
      <VLock
        class="margin-small-left"
        v-model="store.settings.lock.otu"
      />
    </div>
  </div>
</template>

<script setup>
import { useStore } from '../store/useStore'
import Autocomplete from 'components/ui/Autocomplete.vue'
import SelectedItem from './SelectedItem.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()

</script>
