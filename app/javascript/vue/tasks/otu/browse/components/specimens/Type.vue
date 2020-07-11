<template>
  <section-panel
    :status="status"
    :title="`${title} (${types.length})`">
    <a name="type-specimens"/>
    <div
      v-if="types.length"
      class="separate-top">
      <ul
        class="no_bullets">
        <li
          v-for="co in collectionObjects"
          :key="co.collection_objects_id">
          <type-information
            :otu="otu"
            :types="types.filter(item => co.collection_objects_id === item.collection_object_id)"
            :specimen="co"/>
        </li>
      </ul>
    </div>
  </section-panel>
</template>

<script>

import SectionPanel from '../shared/sectionPanel'
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
    }
  },
  data () {
    return {
      types: [],
      collectionObjects: []
    }
  },
  watch: {
    otu: {
      handler(newVal) {
        if(newVal) {
          GetCollectionObjects({ type_specimen_taxon_name_id: newVal.taxon_name_id }).then(response => {
            this.collectionObjects = response.body.data.map((item, index) => { return this.createObject(response.body, index) })
            GetTypeMaterials(newVal.taxon_name_id).then(response => {
              this.types = response.body
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
