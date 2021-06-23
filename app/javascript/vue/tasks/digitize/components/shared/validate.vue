<template>
  <div class="warning-component">
    <span
      v-if="showMessage"
      :legend="legend"
      class="warning-validation" 
      @mouseover="showLegend = true"
      @mouseout="showLegend = false"
      data-icon="warning"/>
    <div
      class="warning-message"
      v-if="showLegend && legend.length">
      {{ legend }}
    </div>
  </div>
</template>
<script>
export default {
  props: {
    showMessage: {
      type: Boolean,
      default: false
    },
    legend: {
      type: String,
      required: false,
      default: ''
    }
  },
  data() {
    return {
      showLegend: false
    }
  }
}
</script>
<style lang="scss" module>
  .warning-component {
    .warning-validation {
      cursor: pointer;
    }
    .warning-message {
      border-radius: 2px;
      padding: 0.5em;
      padding-left: 1em;
      padding-right: 1em;
      box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, 0.2);
      position: absolute;
      background-color: #444;
      color: #F5F5F5;
      z-index: 1;
      font-weight: 300;
      font-size: 12px;
    }
  }
</style>
