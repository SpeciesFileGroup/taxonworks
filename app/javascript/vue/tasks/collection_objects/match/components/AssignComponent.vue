<template>
  <div>
    <switch-component
      :options="tabs"
      v-model="view"
    />
    <component
      :ids="ids"
      :is="`${view.replace(' ', '')}Component`"
    />
  </div>
</template>

<script>

import SwitchComponent from 'components/switch'
import TagComponent from './Assign/Tags'
import DeterminationComponent from './Assign/Determinations'
import LoanComponent from './Assign/Loans'
import CollectingEventComponent from './Assign/CollectingEvents'
import AccessionsComponent from './Assign/Accesssions.vue'
import RepositoryComponent from './Assign/Repository.vue'
import PreparationComponent from './Assign/PreparationType.vue'

export default {
  components: {
    AccessionsComponent,
    CollectingEventComponent,
    DeterminationComponent,
    LoanComponent,
    PreparationComponent,
    RepositoryComponent,
    SwitchComponent,
    TagComponent
  },

  props: {
    ids: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      tabs: [
        'Accessions',
        'Collecting Event',
        'Determination',
        'Loan',
        'Preparation',
        'Repository',
        'Tag'
      ],
      view: 'Tag'
    }
  }
}
</script>
