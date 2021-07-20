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
      <namespace-form v-model="namespace"/>
      <namespace-match
        v-if="!namespace.id"
        class="margin-small-left"
        :name="namespace.name"
        @onSelect="setNamespace"/>
    </template>
  </block-layout>
</template>

<script>

import { ref, reactive, onBeforeMount } from 'vue'
import { Namespace } from 'routes/endpoints'
import NamespaceForm from './components/Namespace/NamespaceForm.vue'
import NamespaceMatch from './components/Namespace/NamespaceMatch.vue'
import namespaceObject from './const/namespace.js'
import BlockLayout from 'components/layout/BlockLayout'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

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
    const resetForm = () => { namespace.value = reactive(namespaceObject()) }

    onBeforeMount(async () => {
      const urlParams = new URLSearchParams(window.location.search)
      const namespaceId = urlParams.get('namespace_id')

      namespace.value = namespaceId
        ? reactive((await Namespace.find(namespaceId)).body)
        : reactive(namespaceObject())
    })

    return {
      namespace,
      resetForm
    }
  }
}
</script>
