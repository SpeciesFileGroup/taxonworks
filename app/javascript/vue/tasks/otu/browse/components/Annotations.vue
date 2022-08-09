<template>
  <section-panel
    :status="status"
    :title="title">
    <template 
      v-for="(item, key) in annotations"
      :key="key">
      <div v-if="existAnnotations(item)">
        <h4 v-html="otus.find(otu => otu.id == key).object_tag"/>
        <list-component
          class="margin-medium-left"
          v-if="item.dataAttributes.length"
          title="Data attributes"
          :list="item.dataAttributes"/>
        <list-component
          class="margin-medium-left"
          v-if="item.identifiers.length"
          title="Identifiers"
          :list="item.identifiers"/>
        <list-component
          class="margin-medium-left"
          v-if="item.notes.length"
          title="Notes"
          :list="item.notes"/>
        <list-component
          class="margin-medium-left"
          v-if="item.tags.length"
          title="Tags"
          :list="item.tags"/>
      </div>
    </template>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import ListComponent from './shared/list'
import extendSection from './shared/extendSections'
import { Otu } from 'routes/endpoints'
import { GetterNames } from '../store/getters/getters'

export default {
  mixins: [extendSection],
  components: {
    ListComponent,
    SectionPanel
  },
  computed: {
    otus () {
      return this.$store.getters[GetterNames.GetOtus]
    }
  },
  data () {
    return {
      identifiers: [],
      notes: [],
      dataAttributes: [],
      tags: [],
      annotations: {}
    }
  },
  watch: {
    otus: {
      handler (newVal) {
        const that = this
        async function processArray (array) {
          for (const item of array) {
            that.annotations[item.id] = await that.loadAnnotations(item.id)
          }
        }
        processArray(newVal)
      },
      immediate: true
    }
  },
  methods: {
    async loadAnnotations (id) {
      return new Promise((resolve, reject) => {
        const promises = []
        const annotations = {}

        promises.push(Otu.identifiers(id).then(response => {
          annotations.identifiers = response.body
        }))
        promises.push(Otu.tags(id).then(response => {
          annotations.tags = response.body
        }))
        promises.push(Otu.notes(id).then(response => {
          annotations.notes = response.body
        }))
        promises.push(Otu.dataAttributes(id).then(response => {
          annotations.dataAttributes = response.body
        }))
        Promise.all(promises).then(() => {
          resolve(annotations)
        })
      })
    },
    existAnnotations (annotations) {
      return Object.values(annotations).some(annotation => annotation.length)
    }
  }
}
</script>
