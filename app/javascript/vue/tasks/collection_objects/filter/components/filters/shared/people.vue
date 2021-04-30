<template>
  <div>
    <h4>{{ title }}</h4>
    <smart-selector
      :autocomplete-params="{'roles[]' : role }"
      model="people"
      :klass="klass"
      pin-section="People"
      pin-type="People"
      @selected="addPerson"/>
    <label>
      <input
        v-model="params[paramAny]"
        type="checkbox">
      Any
    </label>
    <display-list
      :list="list"
      label="object_tag"
      :delete-warning="false"
      @deleteIndex="removePerson"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import DisplayList from 'components/displayList'
import { People } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    SmartSelector,
    DisplayList
  },

  props: {
    value: {
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
    }
  },

  data () {
    return {
      list: []
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

  watch: {
    value (newVal) {
      if (!newVal[this.paramPeople].length && this.list.length) {
        this.list = []
      }
    },

    list: {
      handler () {
        this.params[this.paramPeople] = this.list.map(item => item.id)
      },
      deep: true
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
  ::v-deep .vue-autocomplete-input {
    width: 100%
  }
</style>
