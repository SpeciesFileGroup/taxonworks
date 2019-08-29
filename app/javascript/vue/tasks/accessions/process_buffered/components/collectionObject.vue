<template>
  <div>
    <textarea
      v-if="!settings.highlight"
      rows="5"
      class="full_width"
      v-model="collectionObject.buffered_collecting_event"/>
    <div
      class="edit-box"
      v-else>
      <span @mouseup="getSelectionHighlight">{{ collectionObject.buffered_collecting_event }}</span>
    </div>
    <ul class="no_bullets context-menu">

      <li class="middle">
        <span class="separate-right">Highlight to copy</span>
        <switch-slider v-model="settings.highlight"/>
      </li>
    </ul>
  </div>
</template>

<script>

import SwitchSlider from 'components/form/switchSlider'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    SwitchSlider
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },
  data () {
    return {
      edit: false
    }
  },
  watch: {
    collectionObject: {
      handler (newVal) {

      },
      deep: true
    }
  },
  methods: {
    getSelectionHighlight () {
      const selection = window.getSelection().toString()
      if (this.settings.highlight && selection.length) {
        this.$store.commit(MutationNames.SetSelection, selection)
      }
    }
  }
}
</script>
<style scoped>
  .edit-box {
    border: 1px solid gray;
    padding: 1em;
  }
</style>