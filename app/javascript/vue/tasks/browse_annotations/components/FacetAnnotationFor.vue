<template>
  <FacetContainer v-if="selectorConfig && target">
    <h3>For</h3>
    <SmartSelector
      ref="smartSelectorRef"
      :key="selectorConfig.model"
      v-bind="selectorConfig"
      :klass="objectType"
      :target="target"
      :add-tabs="allType ? ['all'] : []"
      buttons
      @selected="addItem"
    >
      <template
        v-if="allType"
        #all
      >
        <VModal
          :container-style="{ width: '500px' }"
          @close="smartSelectorRef.setTab('quick')"
        >
          <template #header>
            <h3>{{ humanize(selectorConfig.model) }} - All</h3>
          </template>
          <template #body>
            <VBtn
              v-for="item in allFiltered"
              :key="item.id"
              class="margin-small-bottom margin-small-right"
              color="primary"
              pill
              v-html="item.object_tag"
              @click="addItem(item)"
            />
          </template>
        </VModal>
      </template>
    </SmartSelector>
    <div
      v-if="selectedItems.length"
      class="separate-top"
    >
      <div
        v-for="item in selectedItems"
        :key="item.id"
        class="horizontal-left-content gap-small middle"
      >
        <SmartSelectorItem
          :item="item"
          @unset="removeItem(item.id)"
        />
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { humanize } from '@/helpers'
import { ControlledVocabularyTerm } from '@/routes/endpoints'

const ALL_TYPE = {
  tags: 'Keyword',
  confidences: 'ConfidenceLevel',
  data_attributes: 'Predicate'
}

const SELECTOR_CONFIG = {
  tags: {
    model: 'keywords',
    autocompleteUrl: '/controlled_vocabulary_terms/autocomplete',
    getUrl: '/controlled_vocabulary_terms/',
    autocompleteParams: { 'type[]': 'Keyword' },
    paramName: 'keyword_id'
  },
  confidences: {
    model: 'confidence_levels',
    autocompleteUrl: '/controlled_vocabulary_terms/autocomplete',
    getUrl: '/controlled_vocabulary_terms/',
    autocompleteParams: { 'type[]': 'ConfidenceLevel' },
    paramName: 'confidence_level_id'
  },
  data_attributes: {
    model: 'predicates',
    autocompleteUrl: '/controlled_vocabulary_terms/autocomplete',
    getUrl: '/controlled_vocabulary_terms/',
    autocompleteParams: { 'type[]': 'Predicate' },
    paramName: 'controlled_vocabulary_term_id'
  }
}

const props = defineProps({
  annotationType: {
    type: String,
    default: null
  },

  objectType: {
    type: String,
    default: undefined
  },

  target: {
    type: String,
    default: undefined
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const smartSelectorRef = ref(null)
const selectedItems = ref([])
const allItems = ref([])

const selectorConfig = computed(() =>
  props.annotationType ? SELECTOR_CONFIG[props.annotationType] : null
)

const paramName = computed(() => selectorConfig.value?.paramName)

const allType = computed(() =>
  props.annotationType ? ALL_TYPE[props.annotationType] : null
)

const allFiltered = computed(() => {
  const selectedIds = selectedItems.value.map(({ id }) => id)
  return allItems.value.filter((item) => !selectedIds.includes(item.id))
})

watch(
  () => props.annotationType,
  (newVal) => {
    selectedItems.value = []
    allItems.value = []

    if (ALL_TYPE[newVal]) {
      loadAllItems(ALL_TYPE[newVal])
    }
  }
)

onBeforeMount(() => {
  if (allType.value) {
    loadAllItems(allType.value)
  }
})

function loadAllItems(type) {
  ControlledVocabularyTerm.where({ type: [type] }).then(({ body }) => {
    allItems.value = body
  })
}

function addItem(item) {
  if (!paramName.value) return
  if (selectedItems.value.some((i) => i.id === item.id)) return

  selectedItems.value.push(item)
  updateParams()
}

function removeItem(id) {
  selectedItems.value = selectedItems.value.filter((i) => i.id !== id)
  updateParams()
}

function updateParams() {
  params.value = {
    ...params.value,
    [paramName.value]: selectedItems.value.map((i) => i.id)
  }
}
</script>
