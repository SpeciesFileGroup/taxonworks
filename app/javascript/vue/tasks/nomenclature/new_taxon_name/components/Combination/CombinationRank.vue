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
        :group="group"
        item-key="rank"
        @update="onUpdate"
        @add="onAdd"
      >
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
              :disabled="disabled"
              @getItem="setTaxon(index, $event)"
              param="term"/>
            <v-btn
              color="primary"
              circle
              title="Press and hold to drag input"
              class="margin-small-left"
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
                <span v-html="element.taxon.object_label"/>
              </span>
            </div>
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
            <radial-annotator :global-id="element.taxon.global_id"/>
            <span
              class="circle-button btn-delete"
              @click="removeTaxonFromCombination(index)"/>
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
import { ref, watch, computed } from 'vue'
import { TaxonName } from 'routes/endpoints'

const props = defineProps({
  options: {
    type: Object,
    required: true
  },

  group: {
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
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'update:modelValue',
  'onUpdate'
])
const taxonList = ref([])

const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const setTaxon = (index, taxon) => {
  TaxonName.find(taxon.id).then(({ body }) => {
    taxonList.value[index].taxon = body
  })
}

const updateOrder = () => {
  props.rankGroup.forEach((rank, index) => {
    taxonList.value[index].rank = rank
  })
}

const checkForDuplicate = (newIndex) => {
  if ((taxonList.value.length - 1) === newIndex) {
    taxonList.value.splice((newIndex - 1), 1)
    newIndex = newIndex - 1
  }
  taxonList.value.splice((newIndex + 1), 1)
}

const onAdd = ({ newIndex }) => {
  checkForDuplicate(newIndex)
  updateOrder()
  updateCombination()
}

const onUpdate = () => {
  updateOrder()
  updateCombination()
}

const removeTaxonFromCombination = (index) => {
  taxonList.value[index].taxon = null
}

const updateCombination = () => {
  Object.assign(combination.value,
    ...taxonList.value.map(({ rank, taxon }) => ({ [rank]: taxon }))
  )

  emit('onUpdate', combination.value)
}

watch(() => props.combination, () => {
  taxonList.value = props.rankGroup.map(rank => ({ rank, taxon: combination[rank] }))
}, { immediate: true })

</script>
