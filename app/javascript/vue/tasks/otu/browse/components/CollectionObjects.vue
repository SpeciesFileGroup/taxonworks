<template>
  <section-panel
    :status="status"
    :name="title"
    :title="`${title} (${collectionObjects.length})`">
    <div
      v-if="collectionObjects.length"
      class="separate-top">
      <ul
        class="no_bullets">
        <li
          v-for="(co, index) in collectionObjects"
          v-if="index < max || showAll"
          :key="co.id">
          <collection-object-row :specimen="co"/>
        </li>
      </ul>
      <p v-if="collectionObjects.length > max">
        <a
          v-if="!showAll"
          class="cursor-pointer"
          @click="showAll = true">Show all
        </a> 
        <a
          v-else
          class="cursor-pointer"
          @click="showAll = false">Show less
        </a>
      </p>
    </div>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import CollectionObjectRow from './specimens/CollectionObjectRow'
import extendSection from './shared/extendSections'
import { GetCollectionObjects } from '../request/resources'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    CollectionObjectRow
  },
  props: {
    otu: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      collectionObjects: [],
      max: 5,
      showAll: false
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if(newVal) {
          GetCollectionObjects({ otu_ids: [newVal.id], current_determinations: true }).then(response => {
            this.collectionObjects = response.body.data.map((item, index) => { return this.createObject(response.body, index) })
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    createObject(list, position) {
      let tmp = {} 
      list.column_headers.forEach((item, index) => {
        tmp[item] = list.data[position][index]
      })
      return tmp
    },
    getSpecimen(id) {
      return this.collectionObjects.find(item => { return item.collection_objects_id === id})
    }
  }
}
</script>