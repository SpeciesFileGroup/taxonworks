<template>
  <div class="content">
    <template v-if="determinationCitations.length">
      <ul class="no_bullets">
        <li
          v-for="citation in determinationCitations"
          :key="citation.id"
          v-html="citation.object_tag"
        ></li>
      </ul>
      <br />
    </template>
    <span class="middle">
      <span class="mark-box button-default separate-right" />
      <span
        ><a
          :href="`/tasks/collection_objects/browse?collection_object_id=${specimen.collection_objects_id}`"
          >Specimen</a
        >
        |
        <a
          :href="`/tasks/accessions/comprehensive?collection_object_id=${specimen.collection_objects_id}`"
          >Edit</a
        ></span
      >
    </span>
    <ul class="no_bullets">
      <li>
        <template v-if="identifiers.length">
          Identifiers:
          <ul>
            <li
              v-for="identifier in identifiers"
              :key="identifier.id"
              v-text="identifier.cached"
            ></li>
          </ul>
        </template>
      </li>
      <li>
        <span>Counts: <b v-html="countAndBiocurations" /></span>
      </li>
      <li>
        <span
          >Repository: <b>{{ repositoryLabel }}</b></span
        >
      </li>
      <li>
        <span
          >Citation: <b><span v-html="citationsLabel" /></b
        ></span>
      </li>
      <li>
        <span
          >Collecting event: <b><span v-html="collectingEventLabel" /></b
        ></span>
      </li>
    </ul>
    <div
      v-if="depictions.length"
      class="margin-medium-top"
    >
      <span class="middle">
        <span class="mark-box button-default separate-right" /> Images
      </span>
      <div class="flex-wrap-row">
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
import { COLLECTION_OBJECT, TAXON_DETERMINATION } from '@/constants'
import {
  BiocurationClassification,
  CollectionObject,
  TaxonDetermination,
  Repository,
  Depiction,
  Citation,
  Identifier,
  CollectingEvent
} from '@/routes/endpoints'

import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'

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
    citationsLabel() {
      return this.citations.length
        ? this.citations.map((item) => item.citation_source_body).join('; ')
        : 'not specified'
    },

    countAndBiocurations() {
      return this.biocurations.length
        ? `${this.specimen.individualCount} ${this.biocurations
            .map((item) => item.object_tag.toLowerCase())
            .join(', ')}`
        : this.specimen.individualCount
    },

    collectingEventLabel() {
      return this.collectingEvent?.object_tag || 'not specified'
    },

    repositoryLabel() {
      return this.repository ? this.repository.name : 'not specified'
    },

    ceLabel() {
      const levels = ['country', 'stateProvince', 'county', 'verbatimLocality']
      const tmp = []

      levels.forEach((item) => {
        if (this.specimen[item]) {
          tmp.push(this.specimen[item])
        }
      })

      return tmp.join(', ')
    }
  },

  data() {
    return {
      alreadyLoaded: false,
      biocurations: [],
      citations: [],
      collectingEvent: undefined,
      collectionObject: {},
      depictions: [],
      determinationCitations: [],
      determinations: [],
      expand: false,
      repository: undefined,
      identifiers: []
    }
  },

  watch: {
    expand(newVal) {
      if (!this.alreadyLoaded) {
        this.alreadyLoaded = true
        this.loadData()
      }
    }
  },

  created() {
    this.loadData()
  },

  methods: {
    loadData() {
      const coId = this.specimen.collection_objects_id

      CollectionObject.find(this.specimen.collection_objects_id, {
        extend: ['citations']
      }).then((response) => {
        const repositoryId = response.body.repository_id

        this.collectionObject = response.body
        if (repositoryId) {
          Repository.find(repositoryId).then((response) => {
            this.repository = response.body
          })
        }
      })

      BiocurationClassification.where({
        biocuration_classification_object_id: coId,
        biocuration_classification_object_type: COLLECTION_OBJECT
      }).then(({ body }) => {
        this.biocurations = body
      })

      CollectingEvent.where({
        collection_object_id: [coId]
      }).then(({ body }) => {
        const [ce] = body
        this.collectingEvent = ce
      })

      Depiction.where({
        depiction_object_id: coId,
        depiction_object_type: COLLECTION_OBJECT
      }).then((response) => {
        this.depictions = response.body
      })

      Citation.where({
        citation_object_id: coId,
        citation_object_type: COLLECTION_OBJECT
      }).then((response) => {
        this.citations = response.body
      })

      Identifier.where({
        identifier_object_id: coId,
        identifier_object_type: COLLECTION_OBJECT
      }).then(({ body }) => {
        this.identifiers = body
      })

      TaxonDetermination.where({
        collection_object_id: [this.specimen.collection_objects_id]
      }).then((response) => {
        const determinations = response.body

        this.determinations = determinations
        determinations.forEach((item) => {
          Citation.where({
            citation_object_id: item.id,
            citation_object_type: TAXON_DETERMINATION
          }).then((citationResponse) => {
            citationResponse.body.forEach((c) => {
              this.determinationCitations.push(c)
            })
          })
        })
      })
    }
  }
}
</script>
