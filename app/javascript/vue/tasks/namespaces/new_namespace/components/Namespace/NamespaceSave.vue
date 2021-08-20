<template>
  <v-btn
    color="create"
    medium
    @click="saveNamespace">
    {{ namespace.id ? 'Update' : 'Create' }}
  </v-btn>
</template>

<script setup>

import { Namespace } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  namespace: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['onSave'])

const saveNamespace = () => {
  const { namespace } = props
  const request = namespace.id
    ? Namespace.update(namespace.id, { namespace })
    : Namespace.create({ namespace })

  request.then(({ body }) => {
    emit('onSave', body)
    TW.workbench.alert.create('Namespace was successfully saved.', 'notice')
  })
}

</script>
