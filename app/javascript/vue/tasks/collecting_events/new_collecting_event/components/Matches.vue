<template>
  <div
    v-if="founded.length"
    class="matches-panel panel content">
    <h3>Matches</h3>
    <spinner-component
      v-if="searching"
      legend="Searching..."/>
    <display-list
      :list="founded"
      label="object_tag"
      :remove="false"
      edit
      @edit="$emit('select', $event)"/>
  </div>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import DisplayList from 'components/displayList'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    DisplayList,
    SpinnerComponent
  },

  props: {
    collectingEvent: {
      type: Object,
      required: true
    }
  },

  emits: ['select'],

  computed: {
    verbatimLabel () {
      return this.collectingEvent.verbatim_label
    },

    founded () {
      return this.list.filter(item => item.id !== this.collectingEvent.id)
    }
  },

  data () {
    return {
      list: [],
      delay: 1000,
      timer: undefined,
      searching: false
    }
  },

  watch: {
    verbatimLabel (newVal) {
      clearTimeout(this.timer)
      if (newVal && newVal.length) {
        this.timer = setTimeout(() => {
          this.getRecent()
        }, this.delay)
      } else {
        this.list = []
      }
    }
  },

  methods: {
    getRecent () {
      this.searching = true
      AjaxCall('get', '/collecting_events.json', {
        params: {
          verbatim_label: this.verbatimLabel,
          per: 5
        }
      }).then(response => {
        this.list = response.body
        this.searching = false
      }, () => { this.searching = false })
    }
  }
}
</script>
<style scoped>
  .matches-panel {
    min-height: 500px;
  }
</style>
