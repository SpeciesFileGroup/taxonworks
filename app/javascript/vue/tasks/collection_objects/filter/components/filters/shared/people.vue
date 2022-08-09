<template>
  <div>
    <div class="flex-separate middle">
      <h3>{{ title }}</h3>
      <SwitchButtom
        v-if="toggle"
        v-model="isPeopleView"
        :options="switchOptions"
      />
    </div>
    <div v-if="isPeopleView">
      <smart-selector
        :autocomplete-params="{'roles[]' : role }"
        model="people"
        :klass="klass"
        pin-section="People"
        pin-type="People"
        label="cached"
        @selected="addPerson"
      />
      <label>
        <input
          v-model="params[paramAny]"
          type="checkbox"
        >
        Any
      </label>
      <display-list
        :list="list"
        label="cached"
        :delete-warning="false"
        @delete-index="removePerson"
      />
    </div>
    <div v-else>
      <label class="display-block">Matches</label>
      <i class="display-block">Allows regular expressions</i>
      <input
        v-model="params.determiner_name_regex"
        class="full_width"
        type="text"
      >
    </div>
  </div>
</template>

<script>

import SwitchButtom from 'tasks/observation_matrices/new/components/newMatrix/switch.vue'
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { People } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    SmartSelector,
    DisplayList,
    SwitchButtom
  },

  props: {
    modelValue: {
      type: Object,
      default: () => ({})
    },

    paramAny: {
      type: String,
      required: true
    },

    paramPeople: {
      type: String,
      required: true
    },

    title: {
      type: String,
      default: ''
    },

    role: {
      type: String,
      required: true
    },

    klass: {
      type: String,
      required: true
    },

    toggle: {
      type: Boolean,
      default: false
    }
  },

  emits: [
    'update:modelValue',
    'toggle'
  ],

  data () {
    return {
      list: [],
      switchOptions: ['People', 'Name'],
      isPeopleView: true
    }
  },

  computed: {
    params: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  watch: {
    modelValue (newVal) {
      if (!newVal[this.paramPeople].length && this.list.length) {
        this.list = []
      }
    },

    list: {
      handler () {
        this.params[this.paramPeople] = this.list.map(item => item.id)
      },
      deep: true
    },

    isPeopleView (newVal) {
      this.$emit('toggle', newVal)
      this.list = []
      this.params.determiner_name_regex = undefined
    }
  },

  created () {
    const urlParams = URLParamsToJSON(location.href)
    const peopleIds = urlParams[this.paramPeople] || []

    this.params[this.paramAny] = urlParams[this.paramAny]
    peopleIds.forEach(id => {
      People.find(id).then(({ body }) => {
        this.addPerson(body)
      })
    })
  },

  methods: {
    addPerson (person) {
      if (!this.list.find(item => item.id === person.id)) {
        this.list.push(person)
      }
    },

    removePerson (index) {
      this.list.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
