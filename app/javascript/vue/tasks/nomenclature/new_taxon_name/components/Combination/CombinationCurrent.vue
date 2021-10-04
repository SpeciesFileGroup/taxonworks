<template>
  <div
    class="original-combination-picker">
    <div class="horizontal-left-content">
      <div class="button-current separate-right">
        <v-btn
          color="create">
          Set as current
        </v-btn>
      </div>
      <div>
        <draggable
          class="flex-wrap-column"
          v-if="!existOriginalCombination"
          v-model="taxonOriginal"
          item-key="id"
          :group="{
            name: 'combination',
            put: isGenus,
            pull: true
          }"
          :animation="150"
          filter=".item-filter"
        >
          <template #item="{ element }">
            <div
              class="horizontal-left-content middle item-draggable">
              <input
                type="text"
                class="normal-input current-taxon"
                :value="element.value.subject_object_tag"
                disabled>
              <span
                class="handle button circle-button button-submit"
                title="Press and hold to drag input"
                data-icon="w_scroll-v"/>
            </div>
          </template>
        </draggable>
      </div>
    </div>
  </div>
</template>

<script setup>

import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import VBtn from 'components/ui/VBtn/index.vue'

const store = useStore()
const currentTaxonName = computed(() => store.getters[GetterNames.GetTaxon])

</script>