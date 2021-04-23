<template>
  <div class="panel content">
    <div class="horizontal-left-content align-start">
      <div
        class="flex-wrap-column full_width"
        v-for="(column, key, index) in componentsOrder"
        :class="{ 'margin-medium-right': (index < lastColumn) }"
        :key="key">
        <h2 v-if="titleSection[key]">{{ titleSection[key] }}</h2>
        <draggable
          class="full_width"
          v-model="componentsOrder[key]"
          :key="key"
          @end="updatePreferences"
          :disabled="!sortable">
          <component
            class="separate-bottom"
            v-for="(componentName) in column"
            v-model="collectingEvent"
            :components-order="componentsOrder"
            :key="componentName"
            :is="componentName"/>
        </draggable>
      </div>
    </div>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import {
  GetUserPreferences,
  UpdateUserPreferences
} from '../request/resources.js'

import {
  ComponentMap,
  ComponentParse,
  ComponentVerbatim,
  VueComponents
} from '../const/components'

export default {
  components: {
    Draggable,
    ...VueComponents
  },

  props: {
    value: {
      type: Object,
      required: true
    },

    sortable: {
      type: Boolean,
      default: false
    }
  },

  computed: {
    lastColumn () {
      return Object.keys(this.componentsOrder).length - 1
    },
    collectingEvent: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    collectingEventId: {
      get () {
        return this.collectingEvent.id
      }
    }
  },

  watch: {
    preferences: {
      handler () {
        const store = this.preferences.layout[this.keyStorage]
        if (store && Object.keys(this.componentsOrder).every(key => store[key].length === this.componentsOrder[key].length)) {
          this.componentsOrder = store
        }
      },
      deep: true
    }
  },
  data () {
    return {
      componentsOrder: {
        componentVerbatim: Object.keys(ComponentVerbatim),
        componentParse: Object.keys(ComponentParse),
        componentMap: Object.keys(ComponentMap)
      },
      titleSection: {
        componentVerbatim: 'Verbatim',
        componentParse: 'Parse'
      },
      preferences: {},
      keyStorage: 'tasks::collectingEvent::componentsOrder'
    }
  },
  created () {
    GetUserPreferences().then(response => {
      this.preferences = response.body
    })
  },
  methods: {
    updatePreferences () {
      UpdateUserPreferences(this.preferences.id, { [this.keyStorage]: this.componentsOrder }).then(response => {
        this.preferences.layout = response.body.preferences
        this.componentsOrder = response.body.preferences.layout[this.keyStorage]
      })
    }
  }
}
</script>
