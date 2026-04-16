<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <div>
      <SmartSelector
        class="separate-bottom"
        model="sources"
        klass="Depiction"
        label="cached"
        pin-section="Sources"
        pin-type="Source"
        @selected="(source) => addSource(source)"
      />

      <label
        v-if="!!paramAll"
        data-help="If checked, filter results must match all items listed here"
      >
        <input
          v-model="params[paramAll]"
          type="checkbox"
        />
        All
      </label>

      <DisplayList
        :list="list"
        label="cached"
        :delete-warning="false"
        soft-delete
        @delete-index="(index) => removeSource(index)"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { Source } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { onMounted, ref, watch } from 'vue'

const props = defineProps({
  paramAll: {
    type: String,
    required: false
  },

  paramSource: {
    type: String,
    default: 'source_id'
  },

  title: {
    type: String,
    default: 'Source'
  },

  klass: {
    type: String,
    required: true
  },
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

const list = ref([])

watch(
  params,
  (newVal) => {
    if (!newVal[props.paramSource]?.length && list.value.length) {
      list.value = []
    }
  }
)

watch(
  list,
  () => {
    params.value[props.paramSource] = list.value.map((item) => item.id)
  },
  { deep: true }
)

onMounted(() => {
  const urlParams = URLParamsToJSON(location.href)
  const sourceIds = urlParams[props.paramSource] || []

  if (props.paramAll) {
    params.value[props.paramAll] = urlParams[props.paramAll]
  }

  sourceIds.forEach((id) => {
    Source.find(id).then(({ body }) => {
      addSource(body)
    })
  })
})

function addSource(source) {
  if (!list.value.find((item) => item.id === source.id)) {
    list.value.push(source)
  }
}

function removeSource(index) {
  list.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
