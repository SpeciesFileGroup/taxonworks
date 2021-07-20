<template>
  <div class="horizontal-left-content align-start">
    <div>
      <namespace-institution v-model="namespace.institution"/>
      <div class="field label-above">
        <label>Name</label>
        <input
          v-model="namespace.name"
          type="text">
      </div>
      <div class="field label-above">
        <label>Short name</label>
        <input
          v-model="namespace.short_name"
          type="text">
      </div>
      <div class="field label-above">
        <label>Verbaim short name</label>
        <input
          v-model="namespace.verbatim_short_name"
          type="text">
      </div>
      <namespace-delimiter
        :short-name="namespace.short_name"
        v-model="namespace.delimiter"/>
      <v-btn
        color="create"
        medium
        @click="saveNamespace">
        {{ namespace.id ? 'Update' : 'Create' }}
      </v-btn>
    </div>
  </div>
</template>

<script>

import { computed, reactive } from 'vue'
import { Namespace } from 'routes/endpoints'
import NamespaceInstitution from './NamespaceInstitution.vue'
import NamespaceDelimiter from './NamespaceDelimiter.vue'
import VBtn from 'components/ui/VBtn/index.vue'

export default {
  components: {
    NamespaceInstitution,
    NamespaceDelimiter,
    VBtn
  },

  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'onSave'
  ],

  setup (props, { emit }) {
    const setNamespace = (value) => {
      namespace.value = value
    }
    const namespace = computed({
      get () {
        return props.modelValue
      },
      set (value) {
        emit('update:modelValue', value)
      }
    })

    const saveNamespace = () => {
      const namespaceId = namespace.value.id
      const data = namespace.value
      const request = namespaceId
        ? Namespace.update(namespaceId, { namespace: data })
        : Namespace.create({ namespace: data })

      request.then(({ body }) => {
        emit('onSave', body)
        namespace.value = reactive(body)
        TW.workbench.alert.create('Namespace was successfully saved.', 'notice')
      })
    }

    return {
      namespace,
      setNamespace,
      saveNamespace
    }
  }
}
</script>
