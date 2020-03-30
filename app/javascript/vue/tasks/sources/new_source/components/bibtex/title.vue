<template>
  <div class="field">
    <label>Title</label><br>
    <button
      type="button"
      @click="setItalics">
      <i>Italics</i>
    </button>
    <textarea 
      id="title"
      ref="title"
      v-model="source.title"></textarea>

  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    }
  },
  methods: {
    setItalics() {
      let start = this.$refs.title.selectionStart
      let end = this.$refs.title.selectionEnd
      let title = this.source.title

      if(end === start) {
        this.source.title = title.slice(0, start) + '<i></i>' + title.slice(end)
      } else {
        this.source.title = title.slice(0, start) + '<i>' + title.slice(start, end) + '</i>' + title.slice(end)
      }
    }
  }
}
</script>
