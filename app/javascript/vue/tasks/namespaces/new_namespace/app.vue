<template>
  <h1>New namespace</h1>
  <block-layout>
    <template #header>
      <h3>Namespace</h3>
    </template>
    <template #options>
      <v-btn
        circle
        color="primary"
        @click="resetForm">
        <v-icon
          x-small
          name="reset"/>
      </v-btn>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <namespace-form v-model="namespace"/>
        <namespace-match
          v-if="!namespace.id"
          class="margin-small-left"
          :name="namespace.name"
          @onSelect="setNamespace"/>
      </div>
    </template>
  </block-layout>
</template>

<script>

import { ref, onBeforeMount } from 'vue'
import { Namespace } from 'routes/endpoints'
import NamespaceForm from './components/Namespace/NamespaceForm.vue'
import NamespaceMatch from './components/Namespace/NamespaceMatch.vue'
import namespaceObject from './const/namespace.js'
import BlockLayout from 'components/layout/BlockLayout'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import SetParam from 'helpers/setParam'
import { RouteNames } from 'routes/routes'

export default {
  name: 'NewNamespace',

  components: {
    BlockLayout,
    NamespaceForm,
    NamespaceMatch,
    VBtn,
    VIcon
  },

  setup () {
    const namespace = ref({})
    const resetForm = () => { namespace.value = namespaceObject() }

    onBeforeMount(async () => {
      const urlParams = new URLSearchParams(window.location.search)
      const namespaceId = urlParams.get('namespace_id')

      namespace.value = namespaceId
        ? (await Namespace.find(namespaceId)).body
        : namespaceObject()
    })

    const setNamespace = (value) => {
      namespace.value = value
      SetParam(RouteNames.NewNamespace, 'namespace_id', value.id)
    }

    return {
      setNamespace,
      namespace,
      resetForm
    }
  }
}
</script>
