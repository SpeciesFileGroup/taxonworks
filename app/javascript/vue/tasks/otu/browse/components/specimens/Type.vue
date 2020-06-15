<template>
  <section-panel title="Type specimens">
    <a name="type-specimens"/>
    <div
      v-if="types.length"
      class="separate-top">
      <ul
        class="no_bullets">
        <li
          v-for="type in types"
          :key="type.id">
          <specimen-information
            :otu="otu"
            :type="type"
            :specimen="getSpecimen(type.collection_object_id)"/>
        </li>
      </ul>
    </div>
  </section-panel>
</template>

<script>

import SectionPanel from '../shared/sectionPanel'
import { GetTypeMaterials, GetCollectionObjects } from '../../request/resources.js'
import SpecimenInformation from './Information'
import { GetterNames } from '../../store/getters/getters'

export default {
  components: {
    SectionPanel,
    SpecimenInformation
  },
  props: {
    otu: {
      type: Object
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

<style>

</style>
