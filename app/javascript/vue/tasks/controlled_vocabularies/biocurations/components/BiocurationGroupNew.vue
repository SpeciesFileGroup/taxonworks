<template>
  <div>
    <v-btn
      medium
      color="primary"
      @click="showModal = true"
    >
      Create biocuration group
    </v-btn>

    <v-modal
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Create biocuration group</h3>
      </template>
      <template #body>
        <form-keyword
          @submit="saveKeyword"
        />
      </template>
    </v-modal>
  </div>
</template>
<script setup>
import { ref } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import useStore from '../composables/useStore.js'
import FormKeyword from 'components/Form/FormKeyword.vue'

const { actions } = useStore()
const showModal = ref(false)

const saveKeyword = cvt => {
  actions.createBiocurationGroup({
    ...cvt,
    type: 'BiocurationGroup'
  })
  showModal.value = false
}
</script>
