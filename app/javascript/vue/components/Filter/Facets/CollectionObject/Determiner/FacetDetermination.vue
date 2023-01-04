<template>
  <FacetContainer>
    <h3>Determinations</h3>
    <div class="field">
      <h4>Otu</h4>
      <autocomplete
        url="/otus/autocomplete"
        placeholder="Select an otu"
        param="term"
        label="label_html"
        clear-after
        display="label"
        @get-item="addOtu($event.id)"
      />
    </div>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(otu, index) in otusStore"
          :key="otu.id"
        >
          <span v-html="otu.object_tag" />
          <span
            class="btn-delete button-circle"
            @click="removeOtu(index)"
          />
        </li>
      </ul>
    </div>
    <div class="field">
      <determiner-component
        class="no-shadow no-padding"
        v-model="determination"
        role="Determiner"
        title="Determiner"
        klass="CollectionObject"
        param-people="determiner_id"
        param-any="determiner_id_or"
        toggle
        @toggle="isCurrentDeterminationVisible = $event"
      />
    </div>

    <div
      v-if="isCurrentDeterminationVisible"
      class="field"
    >
      <ul class="no_bullets">
        <li
          v-for="item in currentDeterminationsOptions"
          :key="item.value"
        >
          <label>
            <input
              type="radio"
              :value="item.value"
              name="current-determination"
              v-model="determination.current_determinations"
            >
            {{ item.label }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script>

import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import Autocomplete from 'components/ui/Autocomplete'
import DeterminerComponent from '../../shared/FacetPeople.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Otu } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    DeterminerComponent,
    FacetContainer
  },

  props: {
    modelValue: {
      type: Object,
      default: () => ({})
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      otusStore: [],
      determiners: [],
      isCurrentDeterminationVisible: true,
      currentDeterminationsOptions: [
        {
          label: 'Current and historical',
          value: undefined
        },
        {
          label: 'Current only',
          value: true
        },
        {
          label: 'Historical only',
          value: false
        }
      ]
    }
  },

  computed: {
    determination: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  watch: {
    determination: {
      handler (newVal) {
        if (!newVal.otu_ids?.length) {
          this.otusStore = []
        }
      },
      deep: true
    },

    isCurrentDeterminationVisible () {
      this.determination.current_determinations = undefined
    }
  },

  created () {
    const {
      current_determinations,
      otu_ids = []
    } = URLParamsToJSON(location.href)

    otu_ids.forEach(id => { this.addOtu(id) })
    this.determination.current_determinations = current_determinations
  },

  methods: {
    addOtu (id) {
      Otu.find(id).then(response => {
        this.determination.otu_ids.push(response.body.id)
        this.otusStore.push(response.body)
      })
    },

    removePerson (index) {
      this.determiners.splice(index, 1)
      this.determination.determiner_id.splice(index, 1)
    },

    removeOtu (index) {
      this.determination.otu_ids.splice(index, 1)
      this.otusStore.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
