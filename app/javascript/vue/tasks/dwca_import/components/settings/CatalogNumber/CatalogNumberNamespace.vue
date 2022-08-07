<template>
  <autocomplete
    v-if="!namespace"
    class="full_width"
    placeholder="Search a namespace..."
    autofocus
    clear-after
    url="/namespaces/autocomplete"
    param="term"
    label="label_html"
    @get-item="setNamespace"
  />

  <div
    v-else
    class="flex-separate middle"
  >
    <span>{{ namespaceLabel }}</span>
    <v-btn
      color="destroy"
      circle
      @click="updateCatalogNamespace(null)"
    >
      <v-icon
        name="trash"
        x-small
      />
    </v-btn>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../../store/getters/getters'
import { ActionNames } from '../../../store/actions/actions'
import Autocomplete from 'components/ui/Autocomplete'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  namespaceId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits('update')
const store = useStore()
const namespace = computed(() => store.getters[GetterNames.GetNamespaceFor](props.namespaceId))
const namespaceLabel = computed(() => {
  return namespace.value
    ? `${namespace.value.name || namespace.value.label} (${namespace.value.short_name})`
    : ''
})

const setNamespace = ({ id }) => {
  store.dispatch(ActionNames.LoadNamespace, id)
  updateCatalogNamespace(id)
}

const updateCatalogNamespace = namespaceId => {
  emit('update', { namespaceId })
}

</script>
