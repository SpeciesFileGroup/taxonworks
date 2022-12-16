<template>
  <div class="namespace">
    <h1>{{ namespace.id ? 'Edit' : 'New' }} namespace</h1>
    <v-navbar>
      <div class="flex-separate middle">
        <a
          v-if="namespace.id"
          :href="`/namespaces/${namespace.id}`">
          {{ getPreview }}
        </a>
        <span v-else>{{ getPreview }}</span>

        <div>
          <v-pin
            class="margin-small-right"
            type="Namespace"
            :object-id="namespace.id"
          />
          <namespace-save
            class="margin-small-right"
            :namespace="namespace"
            @onSave="setNamespace"/>
          <v-btn
            color="primary"
            medium
            @click="resetForm">
            New
          </v-btn>
        </div>
      </div>
    </v-navbar>
    <div class="namespace__layout">
      <block-layout>
        <template #header>
          <h3>Namespace</h3>
        </template>
        <template #body>
          <div class="horizontal-left-content align-start">
            <namespace-form v-model="namespace" />
          </div>
        </template>
      </block-layout>
      <namespace-match
        v-if="!namespace.id"
        :name="namespace.name"
        @onSelect="setNamespace"
      />
    </div>
  </div>
</template>

<script setup>

import { ref, computed, onBeforeMount } from 'vue'
import { Namespace } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'
import NamespaceForm from './components/Namespace/NamespaceForm.vue'
import NamespaceMatch from './components/Namespace/NamespaceMatch.vue'
import NamespaceSave from './components/Namespace/NamespaceSave.vue'
import BlockLayout from 'components/layout/BlockLayout'
import VBtn from 'components/ui/VBtn/index.vue'
import VPin from 'components/ui/Pinboard/VPin.vue'
import VNavbar from 'components/layout/NavBar.vue'
import SetParam from 'helpers/setParam'
import makeNamespace from './const/namespace.js'
import Types from './const/types.js'

const namespace = ref({})
const getPreview = computed(() => {
  const type = namespace.value.delimiter
  const shortName = namespace.value.short_name || '<short_name>'

  if (namespace.value.is_virtual) {
    return ''
  }

  switch (type) {
    case Types['Single whitespace']:
      return `${shortName} 123`
    case Types.None:
      return `${shortName}123`
    default:
      return `${shortName}${type || ''}123`
  }
})

onBeforeMount(async () => {
  const urlParams = new URLSearchParams(window.location.search)
  const namespaceId = urlParams.get('namespace_id')

  namespace.value = namespaceId
    ? (await Namespace.find(namespaceId)).body
    : makeNamespace()
})

const setNamespace = (value) => {
  namespace.value = value
  SetParam(RouteNames.NewNamespace, 'namespace_id', value.id)
}

const resetForm = () => { setNamespace(makeNamespace()) }

</script>

<script>
  export default {
    name: 'NewNamespace',
  }
</script>

<style scoped lang="scss">
  .namespace {
    margin: 0 auto;
    max-width: 1240px;

    &__layout {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1em;
    }
  }
</style>
