<template>
  <div>
    <VSpinner
      v-if="isLoading"
      legend="Loading..."
    />

    <div class="namespaces">
      <div class="flex-col">
        <fieldset class="namespace-list">
          <legend>Namespaces from filter (check to replace)</legend>
          <div>
            <ul class="no_bullets">
              <li
                v-for="namespace in namespacesFromQuery"
                :key="namespace.short_name"
              >
                <input
                  type="checkbox"
                  v-model="namespacesToReplace"
                  :value="namespace.id"
                >
                  {{ namespaceDisplay(namespace) }}
                </input>
              </li>
            </ul>
          </div>
        </fieldset>

        <div class="flex-col margin-large-top prefix">
          <label
            :class="[virtualPrefixInputDisabled ? 'disabled' : '']"
            data-help="For query result identifiers that have a virtual namespace, remove the supplied prefix from the identifier while changing the namespace. *Only available when the new namespace is not virtual.* When present only rows with the given prefix are operated on."
          >
            Delete virtual prefix
          </label>
          <input
            :disabled="virtualPrefixInputDisabled"
            type="text"
            :placeholder="hasSourceVirtualNamespace != true ? 'No namespace is virtual' : ''"
            v-model="virtualNamespacePrefix"
            class="margin-small-top"
          />
        </div>
      </div>

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
import { computed, ref, watch } from 'vue'
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

const namespace = defineModel('namespace', {
  type: Object,
  default: () => ({})
})

const virtualNamespacePrefix = defineModel('virtualNamespacePrefix', {
  type: String,
  default: ''
})

const namespacesToReplace = defineModel('namespacesToReplace', {
  type: Array,
  default: () => []
})

const namespacesFromQuery = ref([])
const isLoading = ref(false)
const hasSourceVirtualNamespace = ref(null)

const virtualPrefixInputDisabled = computed(() => {
  return !namespace.value || namespace.value.is_virtual || !hasSourceVirtualNamespace.value
})

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
      hasSourceVirtualNamespace.value = false
      namespacesFromQuery.value.forEach((namespace) => {
        if (namespace.is_virtual) {
          hasSourceVirtualNamespace.value = true
        }
      })
      if (namespacesFromQuery.value.length == 0) {
        namespacesFromQuery.value.push({short_name: '<none>', is_virtual: false})
      }
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
},
{ immediate: true }
)

watch(namespace, (newVal) => {
  if (!newVal || newVal.is_virtual) {
    virtualNamespacePrefix.value = ''
  }
})

function namespaceDisplay(namespace) {
  const s = namespace.is_virtual ? ' (virtual)' : ''
  return `${namespace.verbatim_short_name}/${namespace.short_name}${s}`
}

</script>

<style scoped>
.namespaces {
  display: flex;
  gap: 1.5em;
  width: 100%;
}

.namespace-list {
  flex-grow: 2;
  min-height: 4em;
}

.new-namespace {
  flex-grow: 3;
}
</style>