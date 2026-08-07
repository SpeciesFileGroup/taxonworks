<template>
  <div>
    <a
      class="button-default circle-button btn-citation"
      :href="`/tasks/nomenclature/by_source?source_id=${source.id}`"
      target="blank"
      @mouseover="showSource = true"
      @mouseout="showSource = false"/>
    <div v-if="showSource" class="source-information panel content">
      <span v-html="source.object_tag"/>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    source: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showSource: false
    }
  }
}
</script>

<style lang="scss" scoped>
  .source-information {
    transform: translateX(-100%), translateY(-50%);
    position: fixed;
    left:0px;
    min-width: 400px;
  }
</style>
