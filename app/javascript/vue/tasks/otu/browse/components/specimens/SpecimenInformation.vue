<template>
  <div class="content">
    <template v-if="determinationCitations.length">
      <ul class="no_bullets">
        <li
          v-for="citation in determinationCitations"
          :key="citation.id"
          v-html="citation.object_tag">
        </li>
      </ul>
      <br>
    </template>
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
      class="margin-medium-top">
      <span class="middle">
        <span class="mark-box button-default separate-right" /> Images
      </span>
      <div class="horizontal-left-content">
        <image-viewer
          v-for="depiction in depictions"
          :key="depiction.id"
          :depiction="depiction"
          edit
        />
      </div>
    </div>
  </div>
</template>

<script>

import {
  BiocurationClassification,
  CollectionObject,
  TaxonDetermination,
  Repository
} from 'routes/endpoints'

import { GetterNames } from '../../store/getters/getters'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer'

export default {
  components: {
    ImageViewer
  },

  props: {
    specimen: {
      type: Object,
      required: true
    }
  },

  computed: {
    citationsLabel () {
      return this.citations.length
        ? this.citations.map(item => item.source.cached).join('; ')
        : 'not specified'
    },

    countAndBiocurations () {
      return this.biocurations.length
        ? `${this.specimen.individualCount} ${this.biocurations.map(item => item.object_tag.toLowerCase()).join(', ')}`
        : this.specimen.individualCount
    },

    collectingEvents () {
      return this.$store.getters[GetterNames.GetCollectingEvents]
    },

    collectingEventLabel () {
      const ce = this.collectingEvents.find(item => this.collectionObject.collecting_event_id === item.id)

      return ce ? ce.object_tag : 'not specified'
    },

    repositoryLabel () {
      return this.repository ? this.repository.name : 'not specified'
    },

    ceLabel () {
      const levels = ['country', 'stateProvince', 'county', 'verbatimLocality']
      const tmp = []

      levels.forEach(item => {
        if (this.specimen[item]) { tmp.push(this.specimen[item]) }
      })

      return tmp.join(', ')
    }
  },

  data () {
    return {
      alreadyLoaded: false,
      biocurations: [],
      citations: [],
      collectionObject: {},
      depictions: [],
      determinationCitations: [],
      determinations: [],
      expand: false,
      repository: undefined
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

  created () {
    this.loadData()
  },

  methods: {
    loadData () {
      CollectionObject.find(this.specimen.collection_objects_id).then(response => {
        const repositoryId = response.body.repository_id

        this.collectionObject = response.body
        if (repositoryId) {
          Repository.find(repositoryId).then(response => {
            this.repository = response.body
          })
        }
      })
      BiocurationClassification.where({ biological_collection_object_id: this.specimen.collection_objects_id }).then(response => {
        this.biocurations = response.body
      })
      CollectionObject.depictions(this.specimen.collection_objects_id).then(response => {
        this.depictions = response.body
      })
      CollectionObject.citations(this.specimen.collection_objects_id).then(response => {
        this.citations = response.body
      })
      TaxonDetermination.where({ collection_object_id: this.specimen.collection_objects_id }).then(response => {
        const determinations = response.body

        this.determinations = determinations
        determinations.forEach(item => {
          TaxonDetermination.citations(item.id).then(citationResponse => {
            citationResponse.body.forEach(c => {
              this.determinationCitations.push(c)
            })
          })
        })
      })
    }
  }
}
</script>
