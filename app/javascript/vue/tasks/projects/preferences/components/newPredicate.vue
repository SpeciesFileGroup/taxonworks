<template>
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
  <button
    type="button"
    class="button normal-input button-default"
    @click="showModal = true"
  >
    New predicate
  </button>
</template>

<script setup>
import ModalComponent from 'components/ui/Modal'
import FormKeyword from 'components/Form/FormKeyword.vue'
import { ref } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'

const emit = defineEmits('create')

const showModal = ref(false)

const createPredicate = predicate => {
  ControlledVocabularyTerm.create({ controlled_vocabulary_term: predicate }).then(response => {
    TW.workbench.alert.create('Predicate was successfully created.', 'notice')
    emit('create', response.body)
    showModal.value = false
  })
}

</script>
