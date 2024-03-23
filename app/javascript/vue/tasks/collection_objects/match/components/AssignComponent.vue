<template>
  <div>
    <switch-component
      :options="Object.keys(TABS)"
      v-model="view"
    />
    <component
      :ids="ids"
      :is="TABS[view]"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SwitchComponent from '@/components/ui/VSwitch'
import TagComponent from './Assign/Tags'
import DeterminationComponent from './Assign/Determinations'
import LoanComponent from './Assign/Loans'
import CollectingEventComponent from './Assign/CollectingEvents'
import AccessionsComponent from './Assign/Accesssions.vue'
import RepositoryComponent from './Assign/Repository.vue'
import PreparationComponent from './Assign/PreparationType.vue'
//import CustomAttributes from './Assign/CustomAttributes.vue'

const props = defineProps({
  ids: {
    type: Array,
    required: true
  }
})

const TABS = {
  Accessions: AccessionsComponent,
  'Collecting Event': CollectingEventComponent,
  //'Custom attributes': CustomAttributes,
  Determination: DeterminationComponent,
  Loan: LoanComponent,
  Preparation: PreparationComponent,
  Repository: RepositoryComponent,
  Tag: TagComponent
}

const view = ref('Tag')
</script>
