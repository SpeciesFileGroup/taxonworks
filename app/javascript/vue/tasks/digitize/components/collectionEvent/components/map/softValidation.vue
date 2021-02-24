<template>
  <div
    v-if="validation.length"
    class="panel content soft-validation-box separate-top validation-warning">
    <div class="margin-medium-left">
      <h3>Soft validation</h3>
    </div>
    <div class="body">
      <ul class="no_bullets">
        <li v-for="item in validation">
          <span data-icon="warning" v-html="item.message"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { GetSoftValidation } from '../../../../request/resources'
import { GetterNames } from '../../../../store/getters/getters'

export default {
  computed: {
    lastSave () {
      return this.$store.getters[GetterNames.GetSettings].lastSave
    },
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    }
  },
  data () {
    return {
      validation: []
    }
  },
  watch: {
    lastSave: {
      handler (newVal) {
        if (newVal && this.collectingEvent.id) {
          GetSoftValidation(this.collectingEvent.global_id).then(response => {
            this.validation = response.body.validations.soft_validations
          })
        }
      },
      deep: true,
      immediate: true
    },
    collectingEvent (newVal, oldVal) {
      if (newVal.id && newVal.id != oldVal.id) {
        GetSoftValidation(this.collectingEvent.global_id).then(response => {
          this.validation = response.body.validations.soft_validations
        })
      }
    }
  }
}
</script>

<style>

</style>