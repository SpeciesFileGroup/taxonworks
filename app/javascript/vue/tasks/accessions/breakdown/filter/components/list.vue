<template>
  <div class="panel content">
    <div class="full_width horizontal-left-content align-start">
      <div
        class="waxy-legend margin-large-right"
        v-html="list.svg_legend"
      />
      <div v-html="list.svg_map" />
    </div>
  </div>
</template>

<script setup>

defineProps({
  list: {
    type: Object,
    default: undefined
  }
})
</script>

<style lang="scss">
.waxy-legend {
  figure {
    display: flex;
    flex-direction: row;
    align-items: center;
    margin: 0;
    margin-top: .5em;
  }

  #image-fill {
    height: 20px;
    width: 20px;
    margin-right: 6px;
  }
}
</style>
