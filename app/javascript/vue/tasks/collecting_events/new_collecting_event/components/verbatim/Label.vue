<template>
  <div class="field label-above">
    <label>Label</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="collectingEvent.verbatim_label"/>
    <button
      type="button"
      class="button normal-input button-default"
      @click="parseData">
      Parse fields
    </button>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'
import { ParseVerbatim } from '../../request/resources'

export default {
  mixins: [extendCE],
  methods: {
    parseData () {
      ParseVerbatim(this.collectingEvent.verbatim_label).then(response => {
        if (response.body) {
          this.parsableData = response.body

          const parsedFields = Object.assign({},
            this.parsableData.date,
            this.parsableData.geo.verbatim,
            this.parsableData.elevation,
            this.parsableData.collecting_method)

          this.collectingEvent = Object.assign({}, this.collectingEvent, parsedFields)
          TW.workbench.alert.create('Label value parsed.', 'notice')
        } else {
          TW.workbench.alert.create('No label value to convert.', 'error')
        }
      })
    }
  }
}
</script>
