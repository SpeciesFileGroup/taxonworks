<template>
  <div>
    <a
      class="button-default circle-button btn-citation"
      :href="nomenclatureRoute()"
      target="blank"
      @mouseover="showSource = true"
      @mouseout="showSource = false"/>
    <div v-if="showSource" class="source-information panel content">
      <span v-html="source.object_tag"/>
    </div>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'

export default {
  props: {
    source: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      showSource: false
    }
  },
  methods: {
    nomenclatureRoute () {
      return `${RouteNames.NomenclatureBySource}?source_id=${this.source.id}`
    }
  }
}
</script>

<style lang="scss" module>
  .source-information {
    transform: translateX(-100%), translateY(-50%);
    position: fixed;
    left:0px;
    min-width: 400px;
  }
</style>