<template>
  <div>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>New predicate</h3>
      </template>
      <template #body>
        <form-keyword @submit="createPredicate" />
      </template>
    </modal-component>
    <v-btn
      color="primary"
      @click="showModal = true"
    >
      New predicate
    </v-btn>
  </div>
</template>

<script setup>
import ModalComponent from 'components/ui/Modal'
import FormKeyword from 'components/Form/FormKeyword.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { ref } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'

const emit = defineEmits('create')

const showModal = ref(false)

const createPredicate = predicate => {
  ControlledVocabularyTerm.create({
    controlled_vocabulary_term: {
      ...predicate,
      type: 'Predicate'
    }
  }).then(response => {
    TW.workbench.alert.create('Predicate was successfully created.', 'notice')
    emit('create', response.body)
    showModal.value = false
  })
}

</script>
