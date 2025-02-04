<template>
  <FacetContainer>
    <h3>
      Matching identifiers
      <template v-if="identifiersCount"> ({{ identifiersCount }}) </template>
    </h3>
    <div class="label-above">
      <textarea
        v-tabkey
        v-model="matchIdentifiers"
        class="full_width"
        placeholder="Paste or type identifiers..."
        rows="5"
      />
    </div>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="params.match_identifiers_caseless"
        />
        Match case
      </label>
    </div>

    <div class="field label-above">
      <label><b>Delimiter</b></label>
      <span class="display-block">
        <i>Use </i>\n<i> for newlines, </i>\t<i> for tabs.</i>
      </span>
      <input
        v-model="delimiterIdentifier"
        type="text"
        class="full_width"
      />
    </div>

    <div class="field horizontal-left-content middle">
      <label>Type: </label>
      <VToggle
        v-model="toggleType"
        :options="['Identifier', 'Internal']"
      />
    </div>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="sortBy"
        />
        Sort as listed
      </label>
    </div>
    <VModal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
      :container-style="{
        width: '80vw'
      }"
    >
      <template #header>
        <h3>
          Matching identifiers
          <template v-if="identifiersCount">
            ({{ identifiersCount }})
          </template>
        </h3>
      </template>
      <template #body>
        <div class="label-above">
          <textarea
            v-tabkey
            class="full_width"
            v-model="matchIdentifiers"
            placeholder="Paste or type identifiers..."
            rows="30"
          />
        </div>
        <div class="field">
          <label>
            <input
              type="checkbox"
              v-model="params.match_identifiers_caseless"
            />
            Match case
          </label>
        </div>

        <div class="field label-above">
          <label><b>Delimiter</b></label>
          <span class="display-block">
            <i>Use </i>\n<i> for newlines, </i>\t<i> for tabs.</i>
          </span>
          <input
            v-model="delimiterIdentifier"
            type="text"
            class="full_width"
          />
        </div>

        <div class="field horizontal-left-content middle">
          <label>Type: </label>
          <VToggle
            v-model="toggleType"
            :options="['Identifier', 'Internal']"
          />
        </div>
        <div class="field">
          <label>
            <input
              type="checkbox"
              v-model="sortBy"
            />
            Sort as listed
          </label>
        </div>
      </template>
    </VModal>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, onBeforeMount, watch } from 'vue'
import { useHotkey } from '@/composables'
import { vTabkey } from '@/directives'
import { getPlatformKey } from '@/helpers'
import VToggle from '@/tasks/observation_matrices/new/components/Matrix/switch.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VModal from '@/components/ui/Modal.vue'

const SORT_BY_VALUE = 'match_identifiers'

const TYPE_PARAMETERS = {
  Internal: 'internal',
  Identifier: 'identifier'
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const type = ref()
const delimiter = ref()
const isModalVisible = ref(false)
const shortcuts = ref([
  {
    keys: [getPlatformKey(), 'Shift', 'M'],
    handler() {
      isModalVisible.value = true
    }
  }
])

useHotkey(shortcuts.value)

const identifiersCount = computed(
  () =>
    delimiter.value &&
    matchIdentifiers.value?.split(
      delimiter.value.replace(/\\n/g, '\n').replace(/\\t/g, '\t')
    ).length
)

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const sortBy = computed({
  get: () => params.value.order_by === SORT_BY_VALUE,
  set: (value) => {
    params.value.order_by = value ? SORT_BY_VALUE : undefined
  }
})

const matchIdentifiers = computed({
  get: () => props.modelValue.match_identifiers,
  set: (value) => {
    if (value) {
      params.value.match_identifiers = value
      params.value.match_identifiers_type = type.value
      params.value.match_identifiers_delimiter = delimiter.value
        .replace(/\\n/g, '\n')
        .replace(/\\t/g, '\t')
    } else {
      params.value.match_identifiers = undefined
      params.value.match_identifiers_type = undefined
      params.value.match_identifiers_delimiter = undefined
    }
  }
})

const delimiterIdentifier = computed({
  get: () => delimiter.value,
  set: (value) => {
    delimiter.value = value

    if (!matchIdentifiers.value) {
      params.value.match_identifiers_delimiter = undefined
    } else {
      params.value.match_identifiers_delimiter = value
    }
  }
})

const toggleType = computed({
  get: () => type.value === TYPE_PARAMETERS.Identifier,
  set: (value) => {
    type.value = value ? TYPE_PARAMETERS.Identifier : TYPE_PARAMETERS.Internal

    if (matchIdentifiers.value) {
      params.value.match_identifiers_type = type.value
    }
  }
})

watch(
  () => params.value.match_idenfiers_delimiter,
  (newVal) => {
    if (!newVal) {
      delimiter.value = undefined
    }
  }
)

onBeforeMount(() => {
  type.value = params.value.match_identifiers_type || TYPE_PARAMETERS.Identifier
  delimiter.value = params.value.match_identifiers_delimiter || '\\n'
})

TW.workbench.keyboard.createLegend(
  `${getPlatformKey()}+shift+m`,
  'Open match identifiers facet in full screen mode',
  'Filter task'
)
</script>
