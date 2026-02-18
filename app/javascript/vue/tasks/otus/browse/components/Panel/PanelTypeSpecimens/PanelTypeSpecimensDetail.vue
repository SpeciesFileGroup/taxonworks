<template>
  <div class="content">
    <template v-if="determinationCitations.length">
      <ul class="no_bullets">
        <li
          v-for="citation in determinationCitations"
          :key="citation.id"
          v-html="citation.object_tag"
        />
      </ul>
      <br />
    </template>
    <span class="middle">
      <span class="mark-box button-default separate-right" />
      <span>
        <a
          :href="`/tasks/collection_objects/browse?collection_object_id=${specimen.collection_objects_id}`"
        >
          Specimen
        </a>
        |
        <a
          :href="`/tasks/accessions/comprehensive?collection_object_id=${specimen.collection_objects_id}`"
        >
          Edit
        </a>
      </span>
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
            />
          </ul>
        </template>
      </li>
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
        <span>
          Collecting event: <b><span v-html="collectingEventLabel" /></b>
        </span>
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
        <ImageViewer
          v-for="depiction in depictions"
          :key="depiction.id"
          :depiction="depiction"
          edit
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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

const props = defineProps({
  specimen: {
    type: Object,
    required: true
  }
})

const biocurations = ref([])
const citations = ref([])
const collectingEvent = ref(undefined)
const depictions = ref([])
const determinationCitations = ref([])
const repository = ref(undefined)
const identifiers = ref([])

const citationsLabel = computed(() =>
  citations.value.length
    ? citations.value.map((item) => item.citation_source_body).join('; ')
    : 'not specified'
)

const countAndBiocurations = computed(() =>
  biocurations.value.length
    ? `${props.specimen.individualCount} ${biocurations.value
        .map((item) => item.object_tag.toLowerCase())
        .join(', ')}`
    : props.specimen.individualCount
)

const collectingEventLabel = computed(
  () => collectingEvent.value?.object_tag || 'not specified'
)

const repositoryLabel = computed(() =>
  repository.value ? repository.value.name : 'not specified'
)

onMounted(() => {
  loadData()
})

async function loadData() {
  const coId = props.specimen.collection_objects_id

  CollectionObject.find(coId, { extend: ['citations'] }).then(({ body }) => {
    if (body.repository_id) {
      Repository.find(body.repository_id).then((response) => {
        repository.value = response.body
      })
    }
  })

  BiocurationClassification.where({
    biocuration_classification_object_id: coId,
    biocuration_classification_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    biocurations.value = body
  })

  CollectingEvent.where({
    collection_object_id: [coId]
  }).then(({ body }) => {
    const [ce] = body
    collectingEvent.value = ce
  })

  Depiction.where({
    depiction_object_id: coId,
    depiction_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    depictions.value = body
  })

  Citation.where({
    citation_object_id: coId,
    citation_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    citations.value = body
  })

  Identifier.where({
    identifier_object_id: coId,
    identifier_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    identifiers.value = body
  })

  TaxonDetermination.where({
    collection_object_id: [coId]
  }).then(({ body }) => {
    body.forEach((item) => {
      Citation.where({
        citation_object_id: item.id,
        citation_object_type: TAXON_DETERMINATION
      }).then(({ body: citationBody }) => {
        citationBody.forEach((c) => {
          determinationCitations.value.push(c)
        })
      })
    })
  })
}
</script>
