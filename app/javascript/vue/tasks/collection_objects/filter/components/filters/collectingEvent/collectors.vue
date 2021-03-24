<template>
  <div>
    <h3>Collectors</h3>
    <fieldset>
      <legend>People</legend>
      <smart-selector
        :autocomplete-params="{'roles[]' : 'Collector'}"
        model="people"
        klass="CollectingEvent"
        pin-section="People"
        pin-type="People"
        @selected="addCollector"/>
    </fieldset>
    <table
      v-if="collectors.length"
      class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <template
          v-for="(item, index) in collectors"
          class="table-entrys-list">
          <row-item
            class="list-complete-item"
            :key="index"
            :item="item"
            label="object_tag"
            :options="{
              AND: true,
              OR: false
            }"
            v-model="item.and"
            @remove="removePerson(index)"
          />
        </template>
      </transition-group>
    </table>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import RowItem from 'tasks/sources/filter/components/filters/shared/RowItem'
import { GetPerson } from '../../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    SmartSelector,
    RowItem
  },
  props: {
    value: {
      type: Object,
      default: () => ({})
    }
  },
  computed: {
    params: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      collectors: []
    }
  },
  watch: {
    value (newVal) {
      if (!newVal.collector_ids.length && !newVal.collector_ids_or.length && this.collectors.length) {
        this.collectors = []
      }
    },
    collectors: {
      handler () {
        this.params = {
          collector_ids: this.collectors.filter(collector => collector.and).map(collector => collector.id),
          collector_ids_or: this.collectors.filter(collector => !collector.and).map(collector => collector.id)
        }
      },
      deep: true
    }
  },
  created () {
    const urlParams = URLParamsToJSON(location.href)
    const {
      collector_ids = [],
      collector_ids_or = []
    } = urlParams

    collector_ids.forEach(id => {
      GetPerson(id).then(response => {
        this.addCollector(response.body, true)
      })
    })

    collector_ids_or.forEach(id => {
      GetPerson(id).then(response => {
        this.addCollector(response.body, false)
      })
    })
  },
  methods: {
    addCollector (collector, and = true) {
      if (!this.collectors.find(item => item.id === collector.id)) {
        this.collectors.push({ ...collector, and })
      }
    },

    removePerson (index) {
      this.collectors.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
