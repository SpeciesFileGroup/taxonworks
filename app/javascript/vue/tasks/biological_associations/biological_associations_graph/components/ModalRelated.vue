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
        <p>
          <i
            >Graphs in which some of the biological relationships of the current
            graph are used
          </i>
        </p>
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th class="w-2"></th>
              <th>Graph</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in graphs"
              :key="item.id"
            >
              <td>
                <div class="horizontal-left-content middle gap-small">
                  <VBtn
                    color="primary"
                    circle
                    @click="emit('select:graph', item)"
                  >
                    <VIcon
                      name="pencil"
                      x-small
                    />
                  </VBtn>
                  <RadialAnnotator :global-id="item.global_id" />
                </div>
              </td>
              <td v-html="item.object_tag" />
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <p>
          <i
            >Biological relationships containing related CollectionObjects/OTUS
          </i>
        </p>
        <VBtn
          color="primary"
          medium
          @click="emit('add:biologicalAssociations', selectedIds)"
          :disabled="!selectedIds.length"
        >
          Add
        </VBtn>
        <table
          class="table-striped table-related-graph margin-small-top margin-small-bottom"
        >
          <thead>
            <tr>
              <th class="w-5">
                <input
                  v-model="toggleSelection"
                  type="checkbox"
                />
              </th>
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
              <td>
                <input
                  type="checkbox"
                  :value="item.id"
                  v-model="selectedIds"
                />
              </td>
              <td
                class="text-ellipsis half_width"
                v-html="item.object.object_tag"
                :title="item.object.object_label"
              />
              <td
                class="text-ellipsis"
                v-html="item.biological_relationship.object_label"
              />
              <td
                class="text-ellipsis half_width"
                v-html="item.subject.object_tag"
                :title="item.subject.object_label"
              />
            </tr>
          </tbody>
        </table>
        <VBtn
          color="primary"
          medium
          @click="emit('add:biologicalAssociations', selectedIds)"
          :disabled="!selectedIds.length"
        >
          Add
        </VBtn>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import { ref, onBeforeMount, computed } from 'vue'
import {
  BiologicalAssociation,
  BiologicalAssociationGraph
} from '@/routes/endpoints'
import { OTU } from '@/constants/index.js'

const props = defineProps({
  relations: {
    type: Array,
    required: true
  },

  currentGraph: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['select:graph', 'add:biologicalAssociations'])
const biologicalAssociations = ref([])
const graphs = ref([])
const isLoading = ref(false)
const selectedIds = ref([])

const toggleSelection = computed({
  get: () => biologicalAssociations.value.length === selectedIds.value.length,
  set(value) {
    selectedIds.value = value
      ? biologicalAssociations.value.map((item) => item.id)
      : []
  }
})

function makeObjectIdPayload() {
  const otuIds = []
  const coIds = []
  const objects = props.relations

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
    biologicalAssociations.value = body.filter(
      (ba) => !props.relations.find((re) => re.id === ba.id)
    )
  })
}

function loadGraphs() {
  const baIds = props.relations.filter(({ id }) => !!id).map((ba) => ba.id)

  if (!baIds.length || !props.currentGraph?.id) return

  const payload = {
    biological_association_id: baIds
  }

  return BiologicalAssociationGraph.where(payload).then(({ body }) => {
    graphs.value = body.filter((graph) => graph.id !== props.currentGraph.id)
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

<style scoped>
.table-related-graph {
  display: table;
  table-layout: fixed;
  width: 100%;
}
.text-ellipsis {
  display: table-cell;
}
</style>
