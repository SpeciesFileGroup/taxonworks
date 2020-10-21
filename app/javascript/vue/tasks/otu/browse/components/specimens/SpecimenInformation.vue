<template>
  <div class="content">
    <span class="middle">
      <span class="mark-box button-default separate-right" />
      <span><a :href="`/tasks/collection_objects/browse?collection_object_id=${specimen.collection_objects_id}`">Specimen</a> | <a :href="`/tasks/accessions/comprehensive?collection_object_id=${specimen.collection_objects_id}`">Edit</a></span>
    </span>
    <ul class="no_bullets">
      <li>
        <span>Counts: <b v-html="countAndBiocurations" /></span>
      </li>
      <li>
        <span>Repository: <b>{{ repositoryLabel }}</b></span>
      </li>
      <li>
        <span>Citation: <b><span v-html="citationsLabel" /></b></span>
      </li>
      <li>
        <span>Collecting event: <b><span v-html="collectingEventLabel" /></b></span>
      </li>
    </ul>
    <div
      v-if="depictions.length"
      class="horizontal-left-content margin-medium-top">
      <span class="middle">
        <span class="mark-box button-default separate-right" /> Images
      </span>
      <image-viewer
        v-for="depiction in depictions"
        :key="depiction.id"
        :depiction="depiction"
      />
    </div>
  </div>
</template>

<script>
import { GetCollectionObject } from '../../request/resources'

import {
  GetBiocurations,
  GetDepictions,
  GetRepository,
  GetCitations
} from '../../request/resources'

import { GetterNames } from '../../store/getters/getters'

export default {
  props: {
    specimen: {
      type: Object,
      required: true
    }
  },
  computed: {
    citationsLabel () {
      return this.citations.length ? this.citations.map(item => { return item.source.cached }).join('; ') : 'not specified'
    },
    countAndBiocurations () {
      return this.biocurations.length ? `${this.specimen.individualCount} ${this.biocurations.map(item => { return item.object_tag.toLowerCase() }).join(', ')}` : this.specimen.individualCount
    },
    collectingEvents () {
      return this.$store.getters[GetterNames.GetCollectingEvents]
    },
    collectingEventLabel () {
      const ce = this.collectingEvents.find(item => {
        return this.specimen.collecting_event_id === item.id
      })
      return ce ? ce.object_tag : 'not specified'
    },
    repositoryLabel () {
      return this.repository ? this.repository.name : 'not specified'
    },
    ceLabel () {
      const levels = ['country', 'stateProvince', 'county', 'verbatimLocality']
      let tmp = []
      levels.forEach(item => {
        if(this.specimen[item]) { tmp.push(this.specimen[item]) }
      })
      return tmp.join(', ')
    }
  },
  data () {
    return {
      depictions: [],
      biocurations: [],
      repository: undefined,
      citations: [],
      expand: false,
      alreadyLoaded: false
    }
  },
  watch: {
    expand (newVal) {
      if (!this.alreadyLoaded) {
        this.alreadyLoaded = true
        this.loadData()
      }
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    loadData () {
      GetCollectionObject(this.specimen.collection_objects_id).then(response => {
        const repositoryId = response.body.repository_id
        GetRepository(repositoryId).then(response => {
          this.repository = response.body
        })
      })
      GetBiocurations(this.specimen.collection_objects_id).then(response => {
        this.biocurations = response.body
      })
      GetDepictions('collection_objects', this.specimen.collection_objects_id).then(response => {
        this.depictions = response.body
      })
      GetCitations('collection_objects', this.specimen.collection_objects_id).then(response => {
        this.citations = response.body
      })
    }
  }
}
</script>
