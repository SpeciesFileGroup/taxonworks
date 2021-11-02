<template>
  <div
    class="original-combination-picker">
    <div class="horizontal-left-content">
      <div class="button-current separate-right">
        <v-btn
          medium
          color="primary"
          @click="setCurrent()">
          Set as current
        </v-btn>
      </div>
      <div>
        <draggable
          class="flex-wrap-column"
          :list="taxonNameList"
          item-key="id"
          :group="{
            name: groupName,
            put: false,
            pull: true
          }"
          :animation="150"
        >
          <template #item="{ element }">
            <div
              class="horizontal-left-content middle item-draggable">
              <input
                type="text"
                class="normal-input current-taxon"
                :value="element.taxon.object_label"
                disabled>
              <v-btn
                class="margin-small-left"
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
          </template>
        </draggable>
      </div>
    </div>
    <hr>
  </div>
</template>

<script setup>

import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import { TaxonName } from 'routes/endpoints'
import Draggable from 'vuedraggable'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  combinationRanks: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['onSet'])

const store = useStore()
const currentTaxonName = computed(() => store.getters[GetterNames.GetTaxon])
const groupName = computed(() => Object.entries(props.combinationRanks).find(([_, ranks]) => Object.keys(ranks).includes(currentTaxonName.value.rank))[0])
const ranks = computed(() => [].concat(...Object.values(props.combinationRanks).map(ranks => Object.keys(ranks))))
const taxonNameList = computed(() => [{
  rank: currentTaxonName.value,
  taxon: store.getters[GetterNames.GetTaxon]
}])

const setCurrent = (taxon = currentTaxonName.value, combination = { [currentTaxonName.value.rank]: currentTaxonName.value }) => {
  TaxonName.find(taxon.parent_id).then(({ body }) => {
    if(ranks.value.includes(taxon.rank)) {
      combination[body.rank] = body
      setCurrent(body, combination)
    } else {
      emit('onSet', combination)
    }
  })
}

</script>
