<template>
  <div class="shape-choose-buttons">
    <div class="margin-medium-bottom">
      <button
        class="button normal-input button-default shrink-button"
        @click="() => {
          showGA = true
          emit('modalVisible', true)
        }"
      >
        Add a Geographic Area
      </button>
    </div>

    <div>
      <button
        class="button normal-input button-default"
        @click="() => {
          showGZ = true
          emit('modalVisible', true)
        }"
      >
        Add a Gazetteer
      </button>
    </div>
  </div>

  <div>
    <VModal
      v-if="showGZ || showGA"
      @close="() => {
        showGZ = false
        showGA = false
        emit('modalVisible', false)
      }"
      :container-style="{
        width: '600px',
        height: '80vh'
      }"
    >
      <template #header>
        <slot name="header"><h3>{{ modalHeader }}</h3></slot>
      </template>

      <template #body>
        <VAutocomplete
          v-if="showGA"
          min="2"
          placeholder="Select a Geographic Area"
          label="label_html"
          display="label"
          clear-after
          param="term"
          :addParams="{ mark: false }"
          url="/geographic_areas/autocomplete"
          @get-item="(item) => addShape(item, GZ_COMBINE_GA)"
        />

        <VAutocomplete
          v-if="showGZ"
          min="2"
          placeholder="Select a Gazetteer"
          label="label_html"
          display="label"
          clear-after
          param="term"
          url="/gazetteers/autocomplete"
          @get-item="(item) => addShape(item, GZ_COMBINE_GZ)"
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VModal from '@/components/ui/Modal.vue'
import { computed, ref } from 'vue'
import {
  GZ_COMBINE_GA,
  GZ_COMBINE_GZ
} from '@/constants/index.js'

const emit = defineEmits(['newShape', 'modalVisible'])

const showGZ = ref(false)
const showGA = ref(false)

const modalHeader = computed(() => {
  if (showGZ.value) {
    return 'Add other Gazetteers to this Gazetteer'
  } else {
    return 'Add Geographic Areas to this Gazetteer'
  }
})

function addShape(item, type) {
  if (type == GZ_COMBINE_GA && item.label_html.includes('without shape')) {
    TW.workbench.alert.create('Only GAs with shape can be added.', 'error')
    return
  }
  emit('newShape', item, type)
}
</script>

<style lang="scss" scoped>
.shape-input {
  width: 400px;
  padding: 1.5em;
  margin-bottom: 1.5em;
  margin-top: 1.5em;
  margin-right: 1em;
}

.shape-choose-buttons {
  display: flex;
  flex-direction: column;
}
</style>