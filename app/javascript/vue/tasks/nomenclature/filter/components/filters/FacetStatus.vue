<template>
  <FacetContainer>
    <h3>Status</h3>
    <smart-selector
      class="capitalize"
      :options="options"
      v-model="view"
    />
    <div class="separate-top">
      <tree-display
        v-if="view == smartOptions.all"
        @close="view = undefined"
        :object-lists="mergeLists"
        modal-title="Relationships"
        display="name"
        @selected="addStatus"
      />
      <ul
        v-if="view == smartOptions.common"
        class="no_bullets"
      >
        <template
          v-for="(item, key) in mergeLists.common"
          :key="key"
        >
          <li v-if="!filterAlreadyPicked(item.type)">
            <label>
              <input
                :value="key"
                @click="addStatus(item)"
                type="radio"
              />
              {{ item.name }}
            </label>
          </li>
        </template>
      </ul>
      <autocomplete
        v-if="view == smartOptions.advanced"
        url=""
        :array-list="
          Object.keys(mergeLists.all).map((key) => mergeLists.all[key])
        "
        label="name"
        :clear-after="true"
        min="3"
        time="0"
        @get-item="addStatus"
        placeholder="Search"
        event-send="autocompleteRelationshipSelected"
        param="term"
      />
    </div>
    <display-list
      label="name"
      set-key="type"
      :delete-warning="false"
      soft-delete
      :list="statusSelected"
      @delete="removeItem"
    />
  </FacetContainer>
</template>

<script>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/VSwitch'
import TreeDisplay from '../treeDisplay'
import Autocomplete from '@/components/ui/Autocomplete'
import DisplayList from '@/components/displayList.vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { mergeStatusList } from '@/helpers/taxonNameClassificationStatusList'
import { TaxonNameClassification } from '@/routes/endpoints'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

export default {
  components: {
    SmartSelector,
    TreeDisplay,
    Autocomplete,
    DisplayList,
    FacetContainer
  },

  props: {
    modelValue: {
      type: Object,
      default: () => ({})
    }
  },

  emits: ['update:modelValue'],

  computed: {
    smartOptions() {
      return OPTIONS
    },

    params: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    },

    classifications() {
      return this.params.taxon_name_classification
    },

    nomenclatureCode() {
      return this.modelValue.nomenclature_code
    }
  },

  data() {
    return {
      options: Object.values(OPTIONS),
      lists: [],
      paramRelationships: undefined,
      view: OPTIONS.common,
      statusList: {},
      statusSelected: [],
      mergeLists: {},
      relationships: [],
      typeSelected: undefined
    }
  },

  watch: {
    classifications(newVal) {
      if (newVal?.length || !this.statusSelected.length) return

      this.statusSelected = []
    },

    statusSelected: {
      handler(newVal) {
        this.params.taxon_name_classification = newVal.map(
          (status) => status.type
        )
      },

      deep: true
    },

    nomenclatureCode: {
      handler() {
        if (Object.keys(this.statusList).length) {
          this.merge()
        }
      }
    }
  },

  created() {
    TaxonNameClassification.types()
      .then((response) => {
        this.statusList = response.body
        this.merge()

        const params = URLParamsToJSON(location.href)
        if (params.taxon_name_classification) {
          params.taxon_name_classification.forEach((classification) => {
            this.addStatus(this.mergeLists.all[classification])
          })
        }
      })
      .catch(() => {})
  },

  methods: {
    merge() {
      // latinized (gender/part-of-speech) is always folded in alongside
      // whichever nomenclatural code(s) are selected.
      const codes = this.nomenclatureCode
        ? [this.nomenclatureCode.toLowerCase(), 'latinized']
        : Object.keys(this.statusList)

      // qualifyAll: same-named statuses exist under more than one code
      // (e.g. 'valid'), so the Advanced search needs the code to tell them apart
      this.mergeLists = mergeStatusList(this.statusList, {
        codes,
        qualifyAll: true
      })
    },

    removeItem(status) {
      this.statusSelected.splice(
        this.statusSelected.findIndex((item) => item.type === status.type),
        1
      )
    },

    addStatus(item) {
      this.statusSelected.push(item)
      this.view = OPTIONS.common
    },

    filterAlreadyPicked(type) {
      return this.statusSelected.find((item) => item.type === type)
    }
  }
}
</script>
