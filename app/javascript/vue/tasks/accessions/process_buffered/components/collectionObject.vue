<template>
  <div>
    <textarea
      v-if="edit"
      rows="5"
      class="full_width"
      v-model="co.buffered_collecting_event"/>
    <div
      class="edit-box"
      v-else>
      <span @mouseup="getSelectionHighlight">{{ co.buffered_collecting_event }}</span>
    </div>
    <ul class="no_bullets context-menu">
      <li>
        <label>
          <input
            type="checkbox"
            v-model="edit">
          Edit in place
        </label>
      </li>
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
  props: {
    collectionObject: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      co: {
        buffered_collecting_event: ''
      },
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