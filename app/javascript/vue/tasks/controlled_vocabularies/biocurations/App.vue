<template>
  <div class="margin-medium-top container-xl mx-auto">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <NavBar>
      <div class="flex-separate middle">
        <div class="horizontal-left-content gap-small">
          <biocuration-group-new class="margin-small-right" />
          <biocuration-class-new />
        </div>
        <div>
          <a :href="RouteNames.ManageControlledVocabularyTask"
            >Manage controlled vocabulary terms</a
          >
        </div>
      </div>
    </NavBar>
    <table class="full_width">
      <thead>
        <tr>
          <th>Group</th>
          <th class="three_quarter_width">Classes</th>
          <th class="w-2" />
        </tr>
      </thead>
      <tbody>
        <biocuration-group
          v-for="group in biocurationGroups"
          :key="group.id"
          :biocuration-group="group"
          @delete="removeBiocurationGroup"
        />
        <tr
          v-if="ungroupedClasses.length"
          class="ungrouped-row"
        >
          <td>Ungrouped</td>
          <td>
            <v-btn
              v-for="item in ungroupedClasses"
              :key="item.id"
              class="margin-small"
            >
              {{ item.object_label }}
            </v-btn>
          </td>
          <td />
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import useStore from './composables/useStore.js'
import BiocurationGroup from './components/BiocurationGroupRow.vue'
import NavBar from '@/components/layout/NavBar.vue'
import BiocurationGroupNew from './components/BiocurationGroupNew.vue'
import BiocurationClassNew from './components/BiocurationClassNew.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'ManageBiocurations'
})

const { getters, actions } = useStore()
const biocurationGroups = computed(() => getters.getBiocurationGroups())
const ungroupedClasses = computed(() =>
  getters.getUngroupedBiocurationClasses()
)
const isLoading = ref(true)

Promise.all([
  actions.requestBiocurationGroups(),
  actions.requestBiocurationClasses()
]).finally(() => {
  isLoading.value = false
})

const removeBiocurationGroup = (group) => {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    actions.destroyBiocurationGroup(group.id)
  }
}
</script>

<style scoped>
.ungrouped-row {
  td {
    border-top: 2px solid var(--border-color);
  }
}
</style>
