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
      <OtuPicker
        v-else
        class="full_width"
        clear-after
        @get-item="store.otu = { ...$event, label: $event.name || $event.label }"
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
import { watch } from 'vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker.vue'
import SelectedItem from './SelectedItem.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()

watch(
  () => store.settings.lock.otu,
  newVal => {
    if (!newVal) {
      store.otu = undefined
    }
  }
)

</script>
