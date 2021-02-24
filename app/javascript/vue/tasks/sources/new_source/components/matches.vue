<template>
  <div
    class="matches-panel">
    <spinner-component
      v-if="searching"
      legend="Searching..."/>
    <display-list
      class="panel"
      v-if="founded.length"
      :list="founded"
      label="object_tag"
      :remove="false"
      :edit="true"
      @edit="source = $event"/>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import AjaxCall from 'helpers/ajaxCall'
import DisplayList from 'components/displayList'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    DisplayList,
    SpinnerComponent
  },
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        return this.$store.commit(MutationNames.SetSource, value)
      }
    },
    saving () {
      return this.$store.getters[GetterNames.GetSettings].saving
    }
  },
  data () {
    return {
      founded: [],
      oldVal: undefined,
      delay: 1000,
      timer: undefined,
      searching: false
    }
  },
  watch: {
    source: {
      handler(newVal) {
        if(!newVal.title) {
          clearTimeout(this.timer)
          this.searching = false
          this.founded = []
        } else if (newVal.title != this.oldVal) {
          this.searching = true
          clearTimeout(this.timer)
          if(newVal.title == undefined || newVal.title == '') {
            this.founded = []
          }
          else {
            this.timer = setTimeout(() => { this.getRecent() }, this.delay)
          }
        }
        this.oldVal = newVal.title
      },
      deep: true,
      immediate: true
    },
    saving (newVal) {
      if(!newVal) {
        this.getRecent ()
      }
    }
  },
  methods: {
    getRecent () {
      this.searching = true
      AjaxCall('get', `/sources?query_term=${this.source.title}&per=5`).then(response => {
        if(this.source.id) {
          let index = response.body.findIndex(item => { return item.id === this.source.id })
          if(index > -1) {
            response.body.splice(index, 1)
          }
        }
        this.founded = response.body
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