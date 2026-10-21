<template>
  <div class="panel content">
    <h3>Add images</h3>
    <VSwitch
      v-model="currentTab"
      class="margin-small-bottom"
      :options="[TAB_OTU, TAB_IMAGE]"
    />
    <KeepAlive>
      <OtuDepictions
        v-if="currentTab === TAB_OTU"
        :placed-keys="placedKeys"
        @add="(payload) => emit('add', payload)"
      />
      <ImageSearch
        v-else
        @add="(payload) => emit('add', payload)"
      />
    </KeepAlive>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import OtuDepictions from './OtuDepictions.vue'
import ImageSearch from './ImageSearch.vue'

const TAB_OTU = 'OTU'
const TAB_IMAGE = 'Image'

defineProps({
  placedKeys: {
    type: Set,
    required: true
  }
})

const emit = defineEmits(['add'])

const currentTab = ref(TAB_OTU)
</script>
