<template>
  <div>
    <div class="flex-separate middle">
      <h1>Manage biocuration classes and groups</h1>
      <ul class="context-menu">
        <li>
          <a :href="RouteNames.ManageControlledVocabularyTask">Manage controlled vocabulary terms</a>
        </li>
      </ul>
    </div>

    <nav-bar>
      <div class="horizontal-left-content">
        <biocuration-group-new class="margin-small-right" />
        <biocuration-class-new />
      </div>
    </nav-bar>
    <table class="full_width">
      <thead>
        <tr>
          <th>Group</th>
          <th class="three_quarter_width">
            Classes
          </th>
          <th />
        </tr>
      </thead>
      <tbody>
        <biocuration-group
          v-for="group in biocurationGroups"
          :key="group.id"
          :biocuration-group="group"
          @delete="removeBiocurationGroup"
        />
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import useStore from './composables/useStore.js'
import BiocurationGroup from './components/BiocurationGroupRow.vue'
import NavBar from 'components/layout/NavBar.vue'
import BiocurationGroupNew from './components/BiocurationGroupNew.vue'
import BiocurationClassNew from './components/BiocurationClassNew.vue'
import { RouteNames } from 'routes/routes.js'

const { getters, actions } = useStore()
const biocurationGroups = computed(() => getters.getBiocurationGroups())

actions.requestBiocurationGroups()
actions.requestBiocurationClasses()

const removeBiocurationGroup = group => {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    actions.destroyBiocurationGroup(group.id)
  }
}

</script>

<script>
export default {
  name: 'ManageBiocurations'
}
</script>
