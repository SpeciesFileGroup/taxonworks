<template>
  <fieldset>
    <legend>Source</legend>
    <smart-selector
      model="sources"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      ref="smartSelector"
      pin-section="Sources"
      pin-type="Source"
      @selected="sendItem">
      <div class="margin-medium-top flex-separate middle">
        <label>
          <input
            type="checkbox"
            v-model="value.is_original">
          Is original
        </label>
        <label>
          Pages:
          <input
            class="pages"
            v-model="value.pages"
            placeholder="Pages"
            type="text">
        </label>
      </div>
    </smart-selector>
    <template v-if="selected">
      <p class="horizontal-left-content">
        <span data-icon="ok"/>
        <span v-html="selected"/>
        <span
          class="button circle-button btn-undo button-default"
          @click="unset"/>
      </p>
    </template>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { GetSource } from '../request/resources.js'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      selected: undefined
    }
  },
  watch: {
    value: {
      handler (newVal) {
        if (newVal.source_id == undefined)
          this.selected = undefined
      },
      deep: true
    }
  },
  methods: {
    sendItem (item) {
      let newVal = this.value
      newVal.source_id = item.id
      this.selected = item.hasOwnProperty('label') ? item.label : item.object_tag
      this.$emit('input', newVal)
    },
    setSelected (item) {
      GetSource(item.source_id).then(response => {
        this.selected = response.body.object_tag
      })
    },
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.$emit('input', undefined)
      this.selected = undefined
    }
  }
}
</script>

<style scoped>
  .pages {
    widows: 80px;
  }
</style>

