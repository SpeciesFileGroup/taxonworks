<template>
  <div>
    <navbar-component>
      <div class="flex-separate">
        <ul class="no_bullets context-menu">
          <li
            class="capitalize"
            v-for="item in show">
            <label>
              <input
                type="radio"
                :value="item"
                v-model="filter">
                {{ item }}
            </label>
          </li>
        </ul>
        <div class="horizontal-left-content">
          <button
            type="button"
            class="button button-default normal-input margin-small-right"
            @click="selectAll">
            Select all
          </button>
          <compare-component
            :compare="compare"/>
        </div>
      </div>
    </navbar-component>
    <template
      v-for="(match, recordId) in matchList"
      :key="recordId">
      <div
        v-if="filterView(match)"
        class="panel content">
        <div class="flex-separate">
          <template v-if="(Array.isArray(match) && match.length) || Object.keys(match).length">
            <span><b>{{ recordId }}</b></span>
          </template>
          <template v-else>
            <span>
              <b>{{ recordId }}</b>
            </span>
            <span>
              Unmatched
            </span>
          </template>
        </div>
        <ul v-if="match.length">
          <li v-for="record in match">
            <label>
              <input
                :value="record.id"
                v-model="selected"
                type="checkbox">
            </label>
            <a
              :href="`/tasks/collection_objects/browse?collection_object_id=${record.id}`"
              v-html="record.object_tag"/>
          </li>
        </ul>
      </div>
    </template>
  </div>
</template>

<script>

import CompareComponent from './CompareComponent'
import NavbarComponent from 'components/layout/NavBar'

export default {
  components: {
    CompareComponent,
    NavbarComponent
  },

  props: {
    matchList: {
      type: Object,
      default: () => ({})
    }
  },

  emits: ['selected'],

  computed: {
    compare() {
      if (this.selected.length === 2) {
        const list = [].concat(...Object.values(this.matchList).filter(item => Array.isArray(item)))

        return [
          list.find(item => item.id === this.selected[0]),
          list.find(item => item.id === this.selected[1])
        ]
      }
      else {
        return []
      }
    }
  },

  data () {
    return {
      selected: [],
      show: ['matches', 'unmatched', 'both'],
      filter: 'both'
    }
  },

  watch: {
    selected: {
      handler(newVal) {
        this.$emit('selected', newVal)
      },
      deep: true
    }
  },

  methods: {
    selectAll() {
      this.selected = [].concat(...Object.values(this.matchList).filter(item => Array.isArray(item))).map(item => item.id)
    },

    filterView (record) {
      switch (this.filter) {
        case 'matches':
          return record.length
        case 'unmatched':
          return !record.length
        default:
          return true
      }
    }
  }
}
</script>