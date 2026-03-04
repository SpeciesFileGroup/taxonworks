<template>
  <div class="cright item margin-medium-left">
    <div
      id="cright-panel"
      ref="rightPanelRef"
    >
      <div
        ref="rightPanelContent"
        class="flex-col gap-medium"
      >
        <div>
          <div class="panel content">
            <VAutocomplete
              id="taxonname-autocomplete-search"
              url="/taxon_names/autocomplete"
              param="term"
              :add-params="{ 'type[]': 'Protonym' }"
              label="label_html"
              placeholder="Search a taxon name..."
              clear-after
              @select="(e) => emit('select-taxon', e)"
            />
          </div>
          <CheckChanges />
        </div>
        <TaxonNameBox />
        <SoftValidation
          v-if="checkSoftValidation"
          :validations="validations"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { computed, useTemplateRef } from 'vue'
import { useStore } from 'vuex'
import { useStickyBelow } from '@/composables'
import TaxonNameBox from './taxonNameBox.vue'
import CheckChanges from './checkChanges.vue'
import SoftValidation from '@/components/soft_validations/panel.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

defineProps({
  taxon: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['select-taxon'])

const store = useStore()
const rightPanelRef = useTemplateRef('rightPanelRef')
const rightPanelContent = useTemplateRef('rightPanelContent')

useStickyBelow(rightPanelRef, rightPanelContent)

const validations = computed(() => store.getters[GetterNames.GetSoftValidation])
const checkSoftValidation = computed(
  () =>
    validations.value.taxon_name.list.length ||
    validations.value.taxonStatusList.list.length ||
    validations.value.taxonRelationshipList.list.length
)
</script>
