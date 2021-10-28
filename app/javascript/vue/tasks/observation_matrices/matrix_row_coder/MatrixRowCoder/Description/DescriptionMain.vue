<template>
  <div>
    <v-btn
      medium
      color="primary"
      @click="setModalView(true)">
      Description and diagnosis
    </v-btn>
    <v-modal
      v-if="isVisible"
      @close="setModalView(false)">
      <template #header>
        <h3>Description and diagnosis</h3>
      </template>
      <template #body>
        <description-component class="margin-large-bottom"/>
        <description-diagnosis class="margin-large-bottom"/>
        <description-similar class="margin-large-bottom"/>
      </template>
    </v-modal>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'

import DescriptionComponent from './Description.vue'
import DescriptionSimilar from './DescriptionSimilar.vue'
import DescriptionDiagnosis from './DescriptionDiagnosis.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VModal from 'components/ui/Modal.vue'

export default {
  components: {
    DescriptionComponent,
    DescriptionSimilar,
    DescriptionDiagnosis,
    VModal,
    VBtn
  },

  data () {
    return {
      isVisible: false
    }
  },

  computed: {
    rowId () {
      return this.$store.getters[GetterNames.GetMatrixRow].id
    }
  },

  watch: {
    isVisible (newVal) {
      if (newVal) {
        this.$store.dispatch(ActionNames.RequestDescription, this.rowId)
      }
    }
  },

  methods: {
    loadDescription () {
      this.$store.dispatch(ActionNames.RequestDescription, this.rowId)
    },
    setModalView (value) {
      this.isVisible = value
    }
  }
}
</script>
