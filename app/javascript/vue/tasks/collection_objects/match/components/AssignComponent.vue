<template>
  <div>
    <switch-component
      :options="tabs"
      v-model="view"/>
    <component
      :ids="ids"
      :is="`${view.replace(' ', '')}Component`"/>
  </div>
</template>

<script>

import SwitchComponent from 'components/switch'
import TagComponent from './Assign/Tags'
import DeterminationComponent from './Assign/Determinations'
import LoanComponent from './Assign/Loans'
import CollectingEventComponent from './Assign/CollectingEvents'

export default {
  components: {
    SwitchComponent,
    DeterminationComponent,
    TagComponent,
    LoanComponent,
    CollectingEventComponent
  },

  props: {
    ids: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      tabs: ['Tag', 'Loan', 'Determination', 'Collecting Event'],
      view: 'Tag'
    }
  }
}
</script>
