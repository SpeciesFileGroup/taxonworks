<template>
  <block-layout
    anchor="original-combination"
    :warning="softValidation.length > 0"
    :spinner="!taxon.id"
    v-help.section.subsequentCombination.container>
    <template #header>
      <h3>Subsequent combination</h3>
    </template>
    <template #body>
      <div
        class="original-combination-picker">
        <form class="horizontal-left-content">
          <div class="button-current separate-right">
            <button
              v-if="!existOriginalCombination"
              type="button"
              @click="addOriginalCombination()"
              class="normal-input button button-submit">Set as current
            </button>
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
        </form>
        <hr>
        <original-combination
          class="separate-top separate-bottom"
          v-if="!isGenus"
          nomenclature-group="Species"
          @processed="saveTaxonName"
          @delete="saveTaxonName"
          @create="saveTaxonName"
          :disabled="!existOriginalCombination"
          :options="{
            animation: 150,
            group: {
              name: 'combination',
              put: !isGenus,
              pull: false
            },
            filter: '.item-filter'
          }"
          :relationships="speciesGroup"/>
        <div class="original-combination separate-top separate-bottom">
          <div class="flex-wrap-column rank-name-label">
            <label class="row capitalize"/>
          </div>
          <div
            v-if="existOriginalCombination"
            class="flex-separate middle">
            <span
              class="original-combination-name"
              v-html="taxon.original_combination"/>
            <span
              class="circle-button btn-delete"
              @click="removeAllCombinations()"/>
          </div>
        </div>
      </div>
    </template>
  </block-layout>
</template>

<script setup>

import { ref, computed, watch } from 'vue'
import Draggable from 'vuedraggable'
import BlockLayout from 'components/layout/BlockLayout.vue'

const RANK_LIST = {
  genusGroup: [
    'genus',
    'subgenus'
  ],
  speciesGroup: [
    'species',
    'subspecies',
    'variety',
    'form'
  ]
}

const combination = ref({})

</script>