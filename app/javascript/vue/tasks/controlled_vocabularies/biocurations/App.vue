<template>
  <div>
    <h1>Manage biocuration classes and groups</h1>
    <nav-bar>
      <v-btn
        medium
        color="primary">
        Create biocuration group
      </v-btn>
    </nav-bar>
    <div class="horizontal-left-content">
      <biocuration-group
        v-for="group in biocurationGroups"
        :key="group.id"
        :biocuration-group="group"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints';
import BiocurationGroup from './components/BiocurationGroup.vue'
import NavBar from 'components/layout/NavBar.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const biocurationGroups = ref([])
const biocurationClasses = ref([])

ControlledVocabularyTerm.where({ type: ['BiocurationGroup']}).then(({ body }) => {
  biocurationGroups.value = body
})

ControlledVocabularyTerm.where({ type: ['BiocurationClass']}).then(({ body }) => {
  biocurationClasses.value = body
})

</script>

<script>
export default {
  name: 'ManageBiocurations'
}
</script>

<style>
</style>