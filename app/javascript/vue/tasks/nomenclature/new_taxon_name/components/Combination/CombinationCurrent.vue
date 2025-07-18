<template>
  <div class="original-combination-picker">
    <div class="horizontal-left-content">
      <div class="button-current separate-right">
        <VBtn
          medium
          color="primary"
          :disabled="manualMode"
          @click="setCurrent()"
        >
          Set as current
        </VBtn>
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
            <div class="horizontal-left-content middle item-draggable">
              <input
                type="text"
                class="normal-input current-taxon"
                :value="element.taxon.object_label"
                disabled
              />
              <VBtn
                class="margin-small-left"
                color="primary"
                circle
                title="Press and hold to drag input"
              >
                <VIcon
                  color="white"
                  name="scrollV"
                  small
                />
              </VBtn>
            </div>
          </template>
        </draggable>
      </div>
    </div>
    <hr class="divisor" />
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import { TaxonName } from '@/routes/endpoints'
import Draggable from 'vuedraggable'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  combinationRanks: {
    type: Object,
    required: true
  },

  manualMode: {
    type: Boolean,
    default: false
  }
})
const emit = defineEmits(['onSet'])

const store = useStore()
const currentTaxonName = computed(() => store.getters[GetterNames.GetTaxon])
const groupName = computed(() =>
  props.manualMode
    ? 'subsequent-combination'
    : Object.keys(props.combinationRanks).find((group) =>
        Object.keys(props.combinationRanks[group]).includes(
          currentTaxonName.value.rank
        )
      )
)
const ranks = computed(() =>
  [].concat(
    ...Object.values(props.combinationRanks).map((ranks) => Object.keys(ranks))
  )
)
const taxonNameList = computed(() => [
  {
    rank: currentTaxonName.value,
    taxon: store.getters[GetterNames.GetTaxon]
  }
])

const setCurrent = (taxon = currentTaxonName.value, combination = {}) => {
  if (ranks.value.includes(taxon.rank)) {
    combination[taxon.rank] = taxon
  }

  if (taxon.parent_id) {
    TaxonName.find(taxon.parent_id).then(({ body }) => {
      setCurrent(body, combination)
    })
  } else {
    emit('onSet', combination)
  }
}
</script>
