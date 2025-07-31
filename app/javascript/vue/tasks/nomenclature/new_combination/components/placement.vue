<template>
  <VBtn
    v-if="
      !combination.placement.same &&
      taxon &&
      parent &&
      taxon.parent_id != parent.id
    "
    color="create"
    medium
    @click="moveTaxon"
  >
    Move {{ taxon.name }} to {{ parentName }}
  </VBtn>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const RANKS = ['subspecies', 'species', 'subgenus', 'genus']

const props = defineProps({
  combination: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['create'])

const protonyms = ref([])
const parentName = ref()
const parent = ref()
const taxon = ref()

function getParentName() {
  if (!parent.value) return

  const data = protonyms.value.map((item) => {
    return item.rank === 'subgenus' ? `(${item.taxon.name})` : item.taxon.name
  })

  return data
    .slice(1)
    .reverse()
    .map((protonym) => protonym)
    .join(' ')
}

function moveTaxon() {
  const payload = {
    taxon_name: {
      id: taxon.value.id,
      parent_id: parent.value.id
    },
    extend: ['parent']
  }

  TaxonName.update(taxon.value.id, payload).then(({ body }) => {
    TW.workbench.alert.create(
      `Updated parent of ${body.name} to ${body.parent.object_label}`,
      'notice'
    )
    emit('create', body)
  })
}

function orderRanks() {
  RANKS.forEach((rank) => {
    if (props.combination.protonyms[rank]) {
      protonyms.value.push({
        rank,
        taxon: props.combination.protonyms[rank]
      })
    }
  })
}

onBeforeMount(() => {
  orderRanks()
  const [currentProtonym, parentProtonym] = protonyms.value

  taxon.value = currentProtonym.taxon
  if (parentProtonym) {
    parent.value = parentProtonym.taxon
  }

  parentName.value = getParentName()
})
</script>
