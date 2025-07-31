<template>
  <div class="otu-radial">
    <VBtn
      :title="redirect ? 'Browse OTUs' : 'OTU quick forms'"
      :color="emptyList ? 'create' : redirect ? 'primary' : 'radial'"
      circle
      @click="openApp()"
      @contextmenu.prevent="openApp(true)"
    >
      <VIcon
        :name="redirect ? 'radialOtuRedirect' : 'radialObject'"
        x-small
      />
    </VBtn>
    <modal
      @close="modalOpen = false"
      v-if="modalOpen"
    >
      <template #header>
        <h3>
          <span v-if="list.length">
            <span v-html="taxonName" /> Is linked to {{ list.length }} Otus, go
            to:
          </span>
          <span v-else>
            <span v-html="taxonName" /> Is not linked to an OTU
          </span>
        </h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="item in list"
            :key="item.id"
            class="cursor-pointer"
            v-html="item.object_tag"
            @click="processCall(item)"
          />
        </ul>
        <spinner
          v-if="creatingOtu"
          legend="Creating Otu..."
        />
      </template>
    </modal>
    <OtuRadial
      ref="annotator"
      type="graph"
      :show-bottom="false"
      :global-id="globalId"
    />
  </div>
</template>

<script setup>
import Modal from '@/components/ui/Modal.vue'
import Spinner from '@/components/ui/VSpinner.vue'
import OtuRadial from '@/components/radials/object/radial'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { RouteNames } from '@/routes/routes'
import { Otu, TaxonName } from '@/routes/endpoints'
import { computed, ref, onMounted, useTemplateRef, nextTick } from 'vue'
import { OTU } from '@/constants'

const props = defineProps({
  objectId: {
    type: [String, Number],
    required: false
  },

  otu: {
    type: Object,
    default: undefined
  },

  taxonName: {
    type: String,
    default: ''
  },

  redirect: {
    type: Boolean,
    default: true
  },

  klass: {
    type: String,
    default: undefined
  }
})

const emptyList = computed(() => !list.value.length)

const globalId = ref('')
const modalOpen = ref(false)
const creatingOtu = ref(false)
const loaded = ref(false)
const annotator = useTemplateRef('annotator')
const list = ref([])

onMounted(() => {
  if (!props.otu && props.objectId) {
    getOtuList()
  } else {
    list.value.push(props.otu)
    loaded.value = true
  }
})

function getOtuList() {
  if (props.klass === OTU) {
    Otu.find(props.objectId).then(({ body }) => {
      list.value.push(body)
      loaded.value = true
    })
  } else {
    TaxonName.otus(props.objectId)
      .then(({ body }) => {
        loaded.value = true
        list.value = body
      })
      .catch(() => {})
  }
}

function openApp(newTab = false) {
  if (loaded.value) {
    if (emptyList.value) {
      const otu = { taxon_name_id: props.objectId }
      creatingOtu.value = true

      Otu.create({ otu }).then((response) => {
        list.value.push(response.body)
        processCall(response.body, newTab)
      })
    } else if (list.value.length === 1) {
      processCall(list.value[0], newTab)
    } else {
      modalOpen.value = true
    }
  }
}

function openRadial(otu) {
  globalId.value = otu.global_id
  nextTick(() => {
    annotator.value.openRadialMenu()
  })
}

function processCall(otu, newTab) {
  if (props.redirect) {
    redirectTo(otu.id, newTab)
  } else {
    openRadial(otu)
  }
}

function redirectTo(id, newTab = false) {
  window.open(`/tasks/otus/browse/${id}`, `${newTab ? '_blank' : '_self'}`)
}
</script>
<style lang="scss">
.otu-radial {
  .circle-count {
    bottom: -2px !important;
  }
}
</style>
