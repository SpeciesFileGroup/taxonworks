<template>
  <button
    v-if="getDefault != undefined"
    type="button"
    title="Use default pinned"
    class="button circle-button btn-pin button-default"
    @click="sendDefault()"/>
</template>
<script>
export default {
  props: {
    section: {
      type: String,
      required: true
    },
    label: {
      type: String,
      default: ''
    },
    type: {
      type: String,
      required: true
    }
  },
  mounted: function () {
    var that = this

    this.checkForDefault()
    document.addEventListener('pinboard:insert', function (event) {
      if (event.detail.type == that.type) { that.checkForDefault() }
    })
  },
  data: function () {
    return {
      getDefault: undefined,
      getLabel: undefined
    }
  },
  methods: {
    sendDefault: function () {
      if (this.getDefault) {
        this.$emit('getId', this.getDefault)
      }
      if (this.getLabel) {
        this.$emit('getLabel', this.getLabel)
      }
      if(this.getLabel && this.getDefault) {
        this.$emit('getItem', { id: this.getDefault, label: this.getLabel })
      }
    },
    checkForDefault: function () {
      let defaultElement = document.querySelector(`[data-pinboard-section="${this.section}"] [data-insert="true"]`)
      this.getDefault = (defaultElement ? defaultElement.dataset.pinboardObjectId : undefined)
      this.getLabel = (defaultElement ? defaultElement.querySelector('a').textContent : undefined)
    }
  }
}
</script>
