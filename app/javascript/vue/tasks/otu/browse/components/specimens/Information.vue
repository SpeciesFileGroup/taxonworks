<template>
  <div>
    <div 
      @click="expand = !expand"
      class="inline cursor-pointer">
      <div
        :data-icon="expand ? 'w_less' : 'w_plus'"
        class="expand-box button-default separate-right"/><span class="separate-left" v-if="type" v-html="`[${type}]`"/> <span class="separate-left">{{ ceLabel }}</span>
    </div>
    <div
      v-if="expand"
      class="content">
      <span class="middle">
        <span class="mark-box button-default separate-right"/>
          <a :href="`/tasks/accessions/comprehensive?collection_object_id=${specimen.collection_objects_id}`">Specimen</a>
      </span>
      <ul class="no_bullets">
        <li>
          <span>Counts: <b>{{ biocurations.map(item => { return item.object_tag }).join(', ') }} {{ specimen.individualCount }}</b></span>
        </li>
        <li>
          <span>Repository: <b>{{ repositoryLabel }}</b></span>
        </li>
        <li>
          <span>Data source: <b><span v-html="citationsLabel"/></b></span>
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
import { GetDepictions, GetBiocurations, GetCollectionObject, GetRepository, GetCitations, GetTypeMaterials } from '../../request/resources'
import ImageViewer from '../gallery/ImageViewer'

export default {
  components: {
    ImageViewer
  },
  props: {
    specimen: { 
      type:Object,
      required: true
    },
    otu: {
      type: Object,
      required: true
    },
    type: {
      type: String,
      default: undefined
    }
  },
  computed: {
    repositoryLabel () {
      return this.repository ? this.repository.name : 'not specified'
    },
    citationsLabel () {
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
      types: [],
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
    expand(newVal) {
      if(!this.alreadyLoaded) {
        this.alreadyLoaded = true
        this.loadData()
      }
    }
  },
  methods: {
    loadData () {
      GetDepictions('collection_objects', this.specimen.collection_objects_id).then(response => {
        this.depictions = response.body
      })
      GetBiocurations(this.specimen.collection_objects_id).then(response => {
        this.biocurations = response.body
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

<style module>
  .expand-box {
    width: 18px;
    height: 18px;
    padding: 0px;
    background-size: 10px;
    background-position: center;
  }

  .mark-box {
    width: 10px;
    height: 10px;
    padding: 0px;
  }
</style>