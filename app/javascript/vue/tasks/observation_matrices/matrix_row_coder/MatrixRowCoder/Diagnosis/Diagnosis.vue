<template>
  <div class="middle">
    <span class="margin-small-right">Disagnosable:</span>

    <tippy
      animation="scale"
      placement="bottom"
      size="small"
      inertia
      arrow
    >
      <v-icon
        small
        :color="isDiagnosable ? 'green' : 'attention'"
        :name="isDiagnosable ? 'check' : 'attention'"
      />
      <template #content>
        {{ diagnosisMessage }}
      </template>
    </tippy>

    <v-btn
      class="margin-small-left"
      color="primary"
      medium
      :disabled="!isUpdated"
      @click="loadDescription"
    >
      Recheck
    </v-btn>
  </div>
</template>
<script>

import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { Tippy } from 'vue-tippy'

export default {
  components: {
    VBtn,
    VIcon,
    Tippy
  },

  computed: {
    rowId () {
      return this.$store.getters[GetterNames.GetMatrixRow].id
    },

    isUnsaved () {
      return this.$store.getters[GetterNames.AreDescriptorsUnsaved]
    },

    diagnosisMessage () {
      return this.$store.getters[GetterNames.GetDescription]?.generated_diagnosis
    },

    isDiagnosable () {
      return this.diagnosisMessage !== 'Cannot be separated from other rows in the matrix!'
    }
  },

  data () {
    return {
      isUpdated: false
    }
  },

  watch: {
    isUnsaved (newVal) {
      if (!newVal) {
        this.isUpdated = true
      }
    }
  },

  methods: {
    loadDescription () {
      this.$store.dispatch(ActionNames.RequestDescription, this.rowId)
      this.isUpdated = false
    }
  }
}
</script>
