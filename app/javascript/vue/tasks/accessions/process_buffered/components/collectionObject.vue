<template>
  <div>
    <textarea
      rows="5"
      class="full_width"
      v-model="co.buffered_collecting_event">
    </textarea>
    <div class="middle">
      <a>Edit in place</a> | Highlight to copy
      <switch-slider v-model="editInplace"/>
    </div>
  </div>
</template>

<script>

import SwitchSlider from 'components/form/switchSlider'

export default {
  components: {
    SwitchSlider
  },
  props: {
    collectionObject: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      co: {
        buffered_collecting_event: undefined
      },
      editInplace: true
    }
  },
  watch: {
    collectionObject: {
      handler (newVal) {

      },
      deep: true
    }
  }
}
</script>
