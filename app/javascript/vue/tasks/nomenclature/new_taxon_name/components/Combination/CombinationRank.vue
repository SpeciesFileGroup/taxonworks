<template>
  <div class="original-combination">
    <div class="flex-wrap-column rank-name-label">
      <label
        v-for="rank in rankGroup"
        class="row capitalize"
        :key="rank">
        {{ rank }}
      </label>
    </div>
    <div>
      <draggable
        class="flex-wrap-column"
        v-model="taxonList"
        :options="options"
        :group="options.group"
        item-key="rank"
        @end="_"
        @add="_"
        @update="updateOrder"
        @start="_">
        <template #item="{ element, index }">
          <div
            class="horizontal-left-content middle"
            v-if="!element.taxon">
            <autocomplete
              url="/taxon_names/autocomplete"
              label="label_html"
              min="2"
              clear-after
              :add-params="{ type: 'Protonym', 'nomenclature_group[]': nomenclatureGroup }"
              @getItem="setTaxon(index, $event)"
              param="term"/>
            <v-btn
              color="primary"
              circle
              title="Press and hold to drag input"
            >
              <v-icon
                name="scrollV"
                small
              />
            </v-btn>
          </div>
          <div
            class="original-combination-item horizontal-left-content middle"
            v-else>
            <div>
              <span class="vue-autocomplete-input normal-input combination middle">
                <span v-html="element.taxon.label"/>
              </span>
            </div>
            <v-btn
              color="primary"
              circle
              title="Press and hold to drag input"
            >
              <v-icon
                name="scrollV"
                small
              />
            </v-btn>
            <radial-annotator :global-id="element.taxon.global_id"/>
            <span
              class="circle-button btn-delete"
              @click="removeTaxonFromCombination(element)"/>
          </div>
        </template>
      </draggable>
    </div>
  </div>
</template>

<script setup>

import Draggable from 'vuedraggable'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { ref, watch, computed, onBeforeMount } from 'vue'

const props = defineProps({
  options: {
    type: Object,
    required: true
  },

  rankGroup: {
    type: Object,
    required: true
  },

  nomenclatureGroup: {
    type: String,
    required: true
  },

  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])
const taxonList = ref([])

const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const setTaxon = (index, taxon) => {
  const rank = props.rankGroup[index]

  taxonList.value[index].taxon = taxon
}

const updateOrder = (element, index) => {
  console.log()
}

const removeTaxonFromCombination = () => {}

onBeforeMount(() => {
  taxonList.value = props.rankGroup.map(rank => ({ rank, taxon: combination[rank] }))
})

</script>
