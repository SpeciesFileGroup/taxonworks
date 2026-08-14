<template>
  <FacetContainer>
    <h3>Identifiers</h3>
    <div class="field">
      <label>Identifier</label>
      <div class="horizontal-left-content gap-small">
        <input
          type="text"
          v-model="params.identifier"
        />
        <VSwitch
          v-model="matchOption"
          :options="MATCH_OPTIONS"
        />
      </div>
    </div>
    <div class="field">
      <span class="font-bold">In range (Integers)</span>
      <div class="horizontal-left-content gap-small">
        <div class="field label-above">
          <label>Start:</label>

          <input
            class="w-full"
            type="text"
            v-number-only
            v-model="params.identifier_start"
          />
        </div>
        <div class="field label-above">
          <label>End:</label>
          <input
            class="w-full"
            type="text"
            v-number-only
            v-model="params.identifier_end"
          />
        </div>
      </div>
    </div>
    <span class="font-bold margin-xsmall-bottom">Namespace</span>
    <smart-selector
      model="namespaces"
      klass="Source"
      pin-section="Namespaces"
      pin-type="Namespace"
      @selected="setNamespace"
    />
    <div
      v-if="namespace"
      class="middle flex-separate separate-top"
    >
      <span v-html="namespace.name" />
      <VBtn
        icon
        color="primary"
        variant="tonal"
        @click="unsetNamespace"
      >
        <IconClose class="w-4 h-4" />
      </VBtn>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import IconClose from '@/components/Icon/IconClose.vue'
import { watch, computed, ref, onBeforeMount } from 'vue'
import { Namespace } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { vNumberOnly } from '@/directives'

const MATCH_OPTION = {
  Partial: 'Partial',
  Exact: 'Exact'
}

const MATCH_OPTIONS = Object.values(MATCH_OPTION)

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const namespace = ref()

const matchOption = computed({
  get: () =>
    params.value.identifier_exact ? MATCH_OPTION.Exact : MATCH_OPTION.Partial,
  set: (value) => {
    params.value.identifier_exact =
      value === MATCH_OPTION.Exact ? true : undefined
  }
})

watch(
  () => params.value.identifier,
  (newVal) => {
    if (!newVal) {
      params.value.identifier_exact = undefined
    }
  },
  { deep: true }
)

watch(
  () => params.value.namespace_id,
  (newVal) => {
    if (!newVal) {
      namespace.value = null
    }
  }
)

const setNamespace = (item) => {
  namespace.value = item
  params.value.namespace_id = item.id
}

const unsetNamespace = () => {
  namespace.value = undefined
  params.value.namespace_id = undefined
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.identifier = urlParams.identifier
  params.value.identifier_exact = urlParams.identifier_exact
  params.value.identifier_start = urlParams.identifier_start
  params.value.identifier_end = urlParams.identifier_end

  if (urlParams.namespace_id) {
    Namespace.find(urlParams.namespace_id).then((response) => {
      setNamespace(response.body)
    })
  }
})
</script>

<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
