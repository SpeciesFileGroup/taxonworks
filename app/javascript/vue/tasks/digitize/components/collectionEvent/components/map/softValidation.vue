<template>
  <div
    v-if="validation.length"
    class="panel content soft-validation-box separate-top validation-warning">
    <template v-if="validation.length">
      <h3>Collecting event</h3>
      <ul class="no_bullets">
        <li v-for="item in validation">
          <span data-icon="warning" v-html="item.message"/>
        </li>
      </ul>
    </template>
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
            this.validation = response.validations.soft_validations
          })
        }
      },
      deep: true,
      immediate: true
    }
  }
}
</script>

<style>

</style>