<template>
  <div>
    <VSpinner
      v-if="isLoading"
      legend="Loading..."
    />

    <div class="namespaces">
      <fieldset class="namespace-list">
        <legend>Namespaces from filter</legend>
        <div>
          <ul class="no_bullets">
            <li
              v-for="namespace in namespacesFromQuery"
              :key="namespace"
            >
              {{ namespace }}
            </li>
          </ul>
        </div>
      </fieldset>

      <fieldset class="new-namespace">
        <legend>Replacement namespace</legend>
        <SmartSelector
          model="namespaces"
          klass="objectType"
          pin-section="Namespaces"
          pin-type="Namespace"
          v-model="namespace"
        />
        <SmartSelectorItem
          :item="namespace"
          label="name"
          @unset="() => (namespace = null)"
        />
      </fieldset>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Identifier } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  identifierTypes: {
    type: Array,
    required: true
  },

  filterQuery: {
    type: Object,
    default: () => ({})
  },

  objectType: {
    type: String,
    required: true
  }
})

const namespace = defineModel({
  type: Object,
  default: () => ({})
})

const namespacesFromQuery = ref([])
const isLoading = ref(false)

watch(() => props.identifierTypes, (newVal) => {
  if (newVal.length == 0) {
    namespacesFromQuery.value = []
    return
  }

  const payload = {
    identifier_types: props.identifierTypes,
    filter_query: props.filterQuery
  }

  isLoading.value = true
  Identifier.namespaces(payload)
    .then(({ body }) => {
      namespacesFromQuery.value = body
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
},
{ immediate: true }
)

</script>

<style scoped>
.namespaces {
  display: flex;
  gap: 1.5em;
  width: 100%;
}

.namespace-list {
  flex-grow: 2;
}

.new-namespace {
  flex-grow: 3;
}
</style>