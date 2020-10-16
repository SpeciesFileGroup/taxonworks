<template>
  <div>
    <div 
      @click="expand = !expand"
      class="inline cursor-pointer">
      <div
        :data-icon="expand ? 'w_less' : 'w_plus'"
        class="expand-box button-default separate-right"/><span v-if="type" class="separate-right" v-html="`[${type.type_type} of ${type.original_combination}]`"/> <span>{{ ceLabel }}</span>
    </div>
    <div
      v-if="expand"
      class="content">
      <span class="middle">
        <span class="mark-box button-default separate-right"/>
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
          <span>Citation: <b><span v-html="citationsLabel"/></b></span>
        </li>
        <li>
          <span>Collecting event: <b><span v-html="collectingEventLabel"/></b></span>
        </li>
      </ul>
      <h3 class="middle">
        <span class="mark-box button-default separate-right"/> Images
      </h3>
      <div class="horizontal-left-content">
        <image-viewer 
          v-for="depiction in depictions"
          :key="depiction.id"
          :depiction="depiction"/>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { GetDepictions, GetBiocurations, GetCollectionObject, GetRepository, GetCitations } from '../../request/resources'
import ImageViewer from '../gallery/ImageViewer'

export default {
  components: {
    ImageViewer
  },
  props: {
    specimen: {
      type: Object,
      required: true
    },
    otu: {
      type: Object,
      required: true
    },
    type: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    countAndBiocurations () {
      return this.biocurations.length ? `${this.specimen.individualCount} ${this.biocurations.map(item => { return item.object_tag.toLowerCase() }).join(', ')}` : this.specimen.individualCount

    },
    collectingEvents () {
      return this.$store.getters[GetterNames.GetCollectingEvents]
    },
    collectionObjects () {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
    collectingEventLabel () {
      const ce = this.collectingEvents.find(item => {
        return this.co.collecting_event_id === item.id
      })

      return ce !== undefined ? ce.object_tag : 'not specified'
    },
    co () {
      return this.collectionObjects.find(item => {
        return this.specimen.collection_objects_id === item.id
      })
    },
    repositoryLabel () {
      return this.repository ? this.repository.name : 'not specified'
    },
    citationsLabel () {
      if (this.type) {
        return this.type.origin_citation ? this.type.origin_citation.source.object_tag : 'not specified'
      }
      return this.citations.length ? this.citations.map(item => { return item.source.cached }).join('; ') : 'not specified'
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
      collectionObject: undefined,
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
    GetBiocurations(this.specimen.collection_objects_id).then(response => {
      this.biocurations = response.body
    })
  },
  methods: {
    loadData () {
      GetDepictions('collection_objects', this.specimen.collection_objects_id).then(response => {
        this.depictions = response.body
      })
      GetCollectionObject(this.specimen.collection_objects_id).then(response => {
        this.collectionObject = response.body
        if(this.collectionObject.repository_id) {
          GetRepository(this.collectionObject.repository_id).then(response => {
            this.repository = response.body
          })
        }
        GetCitations('collection_objects', this.specimen.collection_objects_id).then(response => {
          this.citations = response.body
        })
      })
    }
  }
}
</script>
