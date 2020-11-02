<template>
  <section-panel
    :status="status"
    :name="title"
    :title="`${title} (${collectionObjects.length})`">
    <div
      v-if="types.length"
      class="separate-top">
      <ul
        class="no_bullets">
        <li
          v-for="co in collectionObjects"
          :key="co.collection_objects_id">
          <type-information
            :types="types.filter(item => co.collection_objects_id === item.collection_object_id)"
            :specimen="co"/>
        </li>
      </ul>
    </div>
  </section-panel>
</template>

<script>

import SectionPanel from '../shared/sectionPanel'
import { GetterNames } from '../../store/getters/getters'
import { GetTypeMaterials, GetCollectionObjects } from '../../request/resources.js'
import TypeInformation from './TypeInformation'
import extendSection from '../shared/extendSections'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    TypeInformation
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  computed: {
    typeMaterialList () {
      const output = this.types.reduce((acc, v) => {
        acc[v.collection_object_id] = acc[v.collection_object_id] || []
        acc[v.collection_object_id].push(v)
        return acc
      }, {})
      return output
    },
    taxonNames () {
      return this.$store.getters[GetterNames.GetTaxonNames]
    },
    taxonName () {
      return this.$store.getters[GetterNames.GetTaxonName]
    }
  },
  data () {
    return {
      types: [],
      collectionObjects: []
    }
  },
  watch: {
    taxonNames: {
      handler (newVal) {
        if (newVal.length) {
          const currentTaxon = newVal.find(taxon => this.otu.taxon_name_id === taxon.id)
          const data = currentTaxon.id === currentTaxon.cached_valid_taxon_name_id ? newVal : [currentTaxon]

          data.forEach(taxon => {
            GetCollectionObjects({ type_specimen_taxon_name_id: taxon.id }).then(response => {
              this.collectionObjects = this.collectionObjects.concat(response.body.data.map((item, index) => this.createObject(response.body, index)))
              GetTypeMaterials(taxon.id).then(response => {
                this.types = this.types.concat(response.body)
              })
            })
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    createObject (list, position) {
      let tmp = {}
      list.column_headers.forEach((item, index) => {
        tmp[item] = list.data[position][index]
      })
      return tmp
    },
    getSpecimen (id) {
      return this.collectionObjects.find(item => { return item.collection_objects_id === id })
    }
  }
}
</script>
