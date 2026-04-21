<template>
  <div class="otu-radial">
    <VBtn
      :title="redirect ? 'Browse OTUs' : 'OTU quick forms'"
      :color="emptyList ? 'create' : redirect ? 'primary' : 'radial'"
      :disabled="!loaded"
      circle
      @click="openApp()"
      @contextmenu.prevent="openApp(true)"
    >
      <VIcon
        :name="redirect ? 'radialOtuRedirect' : 'radialObject'"
        x-small
      />
    </VBtn>
    <VModal
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
    </VModal>
    <OtuRadial
      ref="annotator"
      type="graph"
      reload
      :show-bottom="false"
      :global-id="globalId"
    />
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import Spinner from '@/components/ui/VSpinner.vue'
import OtuRadial from '@/components/radials/object/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { Otu, TaxonName } from '@/routes/endpoints'
import { computed, ref, watch, useTemplateRef, nextTick } from 'vue'
import { RouteNames } from '@/routes/routes'
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

const emit = defineEmits('create:otu')

const emptyList = computed(() => !list.value.length)

const globalId = ref('')
const modalOpen = ref(false)
const creatingOtu = ref(false)
const loaded = ref(false)
const annotator = useTemplateRef('annotator')
const list = ref([])

watch(
  [() => props.otu, props.objectId],
  () => {
    if (!props.otu && props.objectId) {
      getOtuList()
    } else {
      list.value = [props.otu]
      loaded.value = true
    }
  },
  {
    immediate: true
  }
)

async function getOtuList() {
  try {
    const { body } =
      props.klass === OTU
        ? await Otu.find(props.objectId)
        : await TaxonName.otus(props.objectId)

    loaded.value = true
    list.value = body
  } catch {}
}

function openApp(newTab = false) {
  if (loaded.value) {
    if (emptyList.value) {
      const otu = { taxon_name_id: props.objectId }
      creatingOtu.value = true

      Otu.create({ otu }).then(({ body }) => {
        list.value.push(body)
        processCall(body, newTab)
        emit('create:otu', body)
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
  window.open(
    `${RouteNames.BrowseOtu}?otu_id=${id}`,
    `${newTab ? '_blank' : '_self'}`
  )
}
</script>
<style lang="scss">
.otu-radial {
  .circle-count {
    bottom: -2px !important;
  }
}
</style>
