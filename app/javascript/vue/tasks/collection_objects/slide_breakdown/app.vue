<template>
  <div>
    <h1>Slide breakdown</h1>
    <sled 
      :vertical-lines="vlines"
      :horizontal-lines="hlines"
      :image-width="image.width"
      :image-height="image.height"
      :line-weight="lineWeight"
      :scale="scaleForScreen"
      :file-image="fileImage"
      @onComputeCells="processCells">
    </sled>
  </div>
</template>

<script>

import Sled from '@sfgrp/sled'

export default {
  components: {
    Sled
  },
  data () {
    return {
      vlines: [],
      hlines: [],
      image: {
        width: 0,
        height: 0
      },
      lineWeight: 4,
      scaleForScreen: 1,
      fileImage: undefined

    }
  },
  methods: {
    processCells(cells) {

    }
  }
}
</script>