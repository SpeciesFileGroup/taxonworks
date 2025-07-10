<template>
  <div class="biological_relationships_annotator">
    <div
      v-if="assertedDistribution?.id"
      class="flex-separate gap-small"
    >
      <h3>
        <span v-html="editTitle" />
      </h3>
      <VBtn
        circle
        color="primary"
        @click="resetForm"
      >
        <VIcon
          name="undo"
          small
        />
      </VBtn>
    </div>
    <h3 v-else>New asserted distribution</h3>

    <FormCitation
      v-model="citation"
      v-model:absent="assertedDistribution.is_absent"
      :klass="ASSERTED_DISTRIBUTION"
      :target="ASSERTED_DISTRIBUTION"
      absent-field
      lock-button
      use-session
      @lock="lock.source = $event"
    />
    <div class="margin-small-top margin-small-bottom">
      <VBtn
        v-if="assertedDistribution.id"
        :color="editCitation ? 'create' : 'primary'"
        medium
        @click="saveAssertedDistribution"
      >
        {{ editCitation ? 'Update' : 'Create' }}
      </VBtn>
    </div>
    <DisplayList
      v-if="assertedDistribution.id"
      edit
      class="margin-medium-top"
      label="citation_source_body"
      :list="assertedDistribution.citations"
      @edit="setCitation"
      @delete="removeCitation"
    />

    <div
      v-if="!citation.source_id || assertedDistribution.id"
      class="panel content horizontal-center-content padding-large"
    >
      <h3>Select a source first</h3>
    </div>
    <fieldset
      v-else
      class="separate-bottom"
    >
      <legend>Shape</legend>
      <ShapeSelector
        :focus-on-select="lock.source"
        @select-shape="
          (shape) => {
            assertedDistribution.asserted_distribution_shape_type = shape.shapeType
            assertedDistribution.asserted_distribution_shape_id = shape.id
            saveAssertedDistribution()
          }
        "
      />
    </fieldset>

    <div class="horizontal-left-content">
      <VSpinner
        v-if="isLoading"
        legend="Loading..."
      />
      <VMap
        v-if="list.length"
        width="90%"
        height="300px"
        tooltips
        actions
        :zoom="2"
        :zoom-on-click="false"
        :geojson="shapes"
      />
    </div>
    <TableList
      class="separate-top"
      :list="list"
      @edit="setDistribution"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import TableList from './table.vue'
import DisplayList from '@/components/displayList.vue'
import ShapeSelector from '@/components/ui/SmartSelector/ShapeSelector.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VMap from '@/components/georeferences/map.vue'
import makeEmptyCitation from '../../helpers/makeEmptyCitation.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import { ASSERTED_DISTRIBUTION } from '@/constants/index'
import { AssertedDistribution } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { ref, computed, reactive } from 'vue'
import sortArray from '@/helpers/sortArray'

const EXTEND_PARAMS = {
  embed: ['shape'],
  extend: [
    'asserted_distribution_shape',
    'shape_type',
    'parent',
    'citations',
    'source'
  ]
}

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  objectId: {
    type: Number,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const shapes = computed(() =>
  list.value.map((item) => {
    const shape = item.asserted_distribution_shape.shape
    shape.properties.is_absent = item.is_absent
    return shape
  })
)

const lock = reactive({
  geo: false,
  source: false
})

const assertedDistribution = ref(newAsserted())
const editTitle = ref()
const editCitation = ref()
const isLoading = ref(false)
const citation = ref(makeEmptyCitation())

function setCitation(citation) {
  citation.value = {
    id: citation.id,
    pages: citation.pages,
    source_id: citation.source_id,
    is_original: citation.is_original
  }
  editCitation.value = citation
}

function saveAssertedDistribution() {
  const createdObject = list.value.find(
    (item) =>
      item.asserted_distribution_shape_id ===
        assertedDistribution.value.asserted_distribution_shape_id &&
      item.asserted_distribution_shape_type ===
        assertedDistribution.value.asserted_distribution_shape_type &&
      !!assertedDistribution.value.is_absent === !!item.is_absent
  )
  const params = {
    asserted_distribution: {
      ...assertedDistribution.value,
      citations_attributes: [citation.value]
    },
    ...EXTEND_PARAMS
  }

  const saveRequest = createdObject
    ? AssertedDistribution.update(createdObject.id, params)
    : AssertedDistribution.create(params)

  saveRequest
    .then(({ body }) => {
      TW.workbench.alert.create(
        'Asserted distribution was successfully saved.',
        'notice'
      )

      addToList(body)
      resetForm()
    })
    .catch(() => {})
}

function removeCitation(item) {
  const payload = {
    asserted_distribution: {
      citations_attributes: [
        {
          id: item.id,
          _destroy: true
        }
      ]
    },
    ...EXTEND_PARAMS
  }

  AssertedDistribution.update(assertedDistribution.value.id, payload).then(
    ({ body }) => {
      addToList(body)
      resetForm()
    }
  )
}

function setDistribution(item) {
  resetForm()
  editTitle.value = item.object_tag
  assertedDistribution.value = {
    id: item.id,
    citations: item.citations,
    otu_id: item.otu_id,
    is_absent: item.is_absent,
    asserted_distribution_shape_type: item.asserted_distribution_shape_type,
    asserted_distribution_shape_id: item.asserted_distribution_shape_id,
  }

  editCitation.value = undefined
}

function newAsserted() {
  return {
    id: undefined,
    otu_id: props.objectId,
    asserted_distribution_shape_type: lock.geo
      ? assertedDistribution.value.asserted_distribution_shape_type
      : undefined,
    asserted_distribution_shape_id: lock.geo
      ? assertedDistribution.value.asserted_distribution_shape_id
      : undefined,
    citations: [],
    is_absent: null
  }
}

function resetForm() {
  assertedDistribution.value = {
    ...newAsserted(),
    is_absent: lock.source ? assertedDistribution.value.is_absent : undefined
  }

  citation.value = {
    ...makeEmptyCitation(),
    source_id: lock.source ? citation.value.source_id : undefined,
    pages: lock.source ? citation.value.pages : undefined,
    is_original: lock.source ? citation.value.is_original : undefined
  }
}

function removeItem(item) {
  AssertedDistribution.destroy(item.id)
    .then(() => {
      removeFromList(item)
    })
    .catch(() => {})
}

AssertedDistribution.all({
  otu_id: props.objectId,
  ...EXTEND_PARAMS
})
  .then(({ body }) => {
    isLoading.value = false
    list.value = sortArray('asserted_distribution_shape.name', body)
  })
  .catch(() => {})
</script>
<style lang="scss">
.radial-annotator {
  .biological_relationships_annotator {
    position: relative;
    overflow-y: scroll;

    .pages {
      width: 86px;
    }
    .asserted-map-link {
      position: absolute;
      right: 0px;
    }
  }
}
</style>
