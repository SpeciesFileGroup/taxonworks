<template>
  <table class="full_width">
    <thead>
      <tr>
        <th
          :class="classSort('id')"
          @click="sortTable('id')">
          ID
        </th>
        <th
          :class="classSort('verbatim_locality')"
          @click="sortTable('verbatim_locality')">
          Verbatim locality
        </th>
        <th
          :class="classSort('date_start_string')"
          @click="sortTable('date_start_string')">
          Date start
        </th>
        <th
          :class="classSort('cached_level0_geographic_name')"
          @click="sortTable('cached_level0_geographic_name')">
          Level 1
        </th>
        <th
          :class="classSort('cached_level1_geographic_name')"
          @click="sortTable('cached_level1_geographic_name')">
          Level 2
        </th>
        <th
          :class="classSort('cached_level2_geographic_name')"
          @click="sortTable('cached_level2_geographic_name')">
          Level 3
        </th>
        <th>Options</th>
        <th>Select</th>
      </tr>
    </thead>
    <transition-group
      name="list-complete"
      tag="tbody"
      @mouseout.native="$emit('mouseout', 0)">
      <tr
        v-for="(item, index) in newList"
        :key="item.id"
        class="list-complete-item"
        :class="{'ce-row': highlightId == item.id}"
        @mouseover="$emit('mouseover', item)"
      >
        <td><a :href="`/tasks/collecting_events/browse?collecting_event_id=${item.id}`">{{ item.id }}</a></td>
        <td class="my-column">
          <a
            :href="`/tasks/collecting_events/browse?collecting_event_id=${item.id}`"
            v-html="item.verbatim_locality"
          />
        </td>
        <td>
          <span v-html="item.date_start_string" />
        </td>
        <td>{{ item.cached_level0_geographic_name }}</td>
        <td>{{ item.cached_level1_geographic_name }}</td>
        <td>{{ item.cached_level2_geographic_name }}</td>
        <td class="horizontal-left-content">
          <radial-annotator :global-id="item.global_id" />
          <object-annotator :global-id="item.global_id" />
          <pin-component
            v-if="item.id"
            :object-id="item.id"
            :type="item.base_class" 
          />
          <span
            class="circle-button btn-delete button-default"
            @click="$emit('remove', index)"
          />
        </td>
        <td>
          <checkbox-component
            :val="item.id" 
            v-model="selectedList"/>
        </td>
      </tr>
    </transition-group>
  </table>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import ObjectAnnotator from 'components/radials/navigation/radial'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import CheckboxComponent from './checkboxComponent'

export default {
  components: {
    RadialAnnotator,
    ObjectAnnotator,
    PinComponent,
    CheckboxComponent
  },
  props: {
    list: {
      type: Array,
      required: true
    },
    highlightId: {
      type: [Number, String],
      default: 0
    },
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    selectedList: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  watch: {
    list(newVal) {
      this.newList = newVal.map(ce => {
        ce.date_start_string = this.makeDate(ce.start_date_year, ce.start_date_month, ce.start_date_day)
        return ce
      })
    }
  },
  data() {
    return {
      selected: [],
      newList: [],
      sortColumns: {}
    }
  },
  methods: {
    makeDate(year, month, day) {
      year = year ? year : '';
      month = month ? month : '';
      day = day ? day : '';
      let date = year.toString() + '-' + month.toString() + '-' + day.toString();
      if (date == '--') return '';
      return date
    },
    sortTable(sortProperty) {
      let that = this
      function compare(a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (that.sortColumns[sortProperty] ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (that.sortColumns[sortProperty] ? 1 : -1);
        return 0
      }
      if(this.sortColumns[sortProperty] == undefined) {
        this.sortColumns[sortProperty] = true
      }
      else {
        this.sortColumns[sortProperty] = !this.sortColumns[sortProperty]
      }
      this.list.sort(compare);      
    },
    classSort(value) {
      if(this.sortColumns[value] == true) { return 'headerSortDown' }
      if(this.sortColumns[value] == false) { return 'headerSortUp' }
      return ''
    }
  }
}
</script>

<style scoped>
  .my-column {
    width: 40%;
    min-width: 40%;
    max-width: 40%;
  }

  .ce-row {
    background-color: #BBDDBB
  }

  tr:hover {
    background-color: #BBDDBB
  }
</style>
