<template>
  <VModal
    :container-style="{ maxWidth: '1500px', width: '90vw', minHeight: '50vh' }"
  >
    <template #header>
      <h3>Related</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        full-screen
      />
      <div
        v-if="graphs.length"
        class="margin-medium-bottom"
      >
        <h3>Biological associations graph</h3>
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th></th>
              <th>Graph</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in graphs"
              :key="item.id"
            >
              <td />
              <td v-html="item.object_tag" />
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <h3>Biological associations</h3>
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th>Object</th>
              <th>Relation</th>
              <th>Subject</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in biologicalAssociations"
              :key="item.id"
            >
              <td v-html="item.object.object_tag" />
              <td v-html="item.biological_relationship.object_label" />
              <td v-html="item.subject.object_tag" />
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VSpinner from 'components/spinner.vue'
import VModal from 'components/ui/Modal.vue'
import { ref, onBeforeMount } from 'vue'
import {
  BiologicalAssociation,
  BiologicalAssociationGraph
} from 'routes/endpoints'
import { OTU } from 'constants/index.js'

const props = defineProps({
  relations: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['select:graph'])
const biologicalAssociations = ref([])
const graphs = ref([])
const isLoading = ref(false)

function makeObjectIdPayload() {
  const otuIds = []
  const coIds = []
  const objects = [].concat(
    ...props.relations.map((ba) => [ba.object, ba.subject])
  )

  objects.forEach(({ objectType, id }) => {
    if (objectType === OTU) {
      otuIds.push(id)
    } else {
      coIds.push(id)
    }
  })

  return {
    otu_id: [...new Set(otuIds)],
    collection_object_id: [...new Set(coIds)]
  }
}

function loadRelatedAssociations() {
  const payload = {
    extend: [
      'biological_relationship_types',
      'biological_relationship',
      'subject',
      'object'
    ],
    ...makeObjectIdPayload()
  }

  return BiologicalAssociation.filter(payload).then(({ body }) => {
    biologicalAssociations.value = body
  })
}

function loadGraphs() {
  const graphIds = props.relations.filter(({ id }) => !!id).map((ba) => ba.id)

  if (!graphIds.length) return

  const payload = {
    biological_association_id: graphIds
  }

  return BiologicalAssociationGraph.where(payload).then(({ body }) => {
    graphs.value = body
  })
}

onBeforeMount(async () => {
  if (props.relations.length) {
    isLoading.value = true
    await Promise.allSettled([loadRelatedAssociations(), loadGraphs()])
    isLoading.value = false
  }
})
</script>
