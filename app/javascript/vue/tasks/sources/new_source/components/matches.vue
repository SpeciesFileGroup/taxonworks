<template>
  <div
    v-if="founded.length"
    class="panel">
    <display-list
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
import recent from '../../../../components/radial_object/images/recent'
import DisplayList from 'components/displayList'

export default {
  components: {
    DisplayList
  },
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        return this.$store.commit(MutationNames.SetSource, value)
      }
    }
  },
  data () {
    return {
      founded: [],
      oldVal: undefined,
      delay: 1000,
      timer: undefined
    }
  },
  watch: {
    source: {
      handler(newVal) {
        if (newVal.title != this.oldVal) {
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
    }
  },
  methods: {
    getRecent () {
      AjaxCall('get', `/sources?query_term=${this.source.title}&per=5`).then(response => {
        this.founded = response.body
      })
    }
  }
}
</script>
