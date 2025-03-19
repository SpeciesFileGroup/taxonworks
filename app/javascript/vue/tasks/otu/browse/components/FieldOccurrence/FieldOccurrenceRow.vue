<template>
  <div class="panel margin-small-bottom">
    <div class="horizontal-left-content gap-small middle">
      <VBtn
        color="primary"
        circle
        @click="() => (isExpanded = !isExpanded)"
      >
        <VIcon
          v-if="isExpanded"
          name="arrowDown"
          xx-small
        />
        <VIcon
          v-else
          name="arrowRight"
          xx-small
        />
      </VBtn>
      {{ ceLabel }}
    </div>
    <div
      v-if="isExpanded"
      class="content margin-medium-left"
    >
      <div class="middle horizontal-left-content gap-small">
        <span class="mark-box button-default separate-right" />

        <a
          :href="`${RouteNames.BrowseFieldOccurrence}?field_occurrence_id=${fieldOccurrence.id}`"
          >Field occurrence</a
        >
        |
        <a
          :href="`${RouteNames.NewFieldOccurrence}?field_occurrence_id=${fieldOccurrence.id}`"
          >Edit</a
        >
      </div>

      <ul>
        <li
          v-for="determination in determinations"
          :key="determination.id"
          v-html="determination.object_tag"
        ></li>
      </ul>
      <ul class="no_bullets">
        <li>
          <span>Total: <b v-html="fieldOccurrence.total" /></span>
        </li>
        <li>
          <span
            >Collecting event:
            <b><span v-html="collectingEvent?.object_tag" /></b
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
          <ImageViewer
            v-for="depiction in depictions"
            :key="depiction.id"
            :depiction="depiction"
            edit
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { FIELD_OCCURRENCE } from '@/constants'
import { Depiction, TaxonDetermination } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { GetterNames } from '../../store/getters/getters'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  fieldOccurrence: {
    type: Object,
    required: true
  }
})

const store = useStore()
const depictions = ref([])
const determinations = ref([])
const isExpanded = ref(false)
const ceLabel = computed(() => {
  const levels = ['country', 'stateProvince', 'county', 'verbatimLocality']

  return levels
    .map((key) => props.fieldOccurrence.dwc_occurrence[key])
    .filter(Boolean)
    .join(', ')
})

const collectingEvent = computed(() =>
  store.getters[GetterNames.GetCollectingEvents].find(
    (c) => c.id === props.fieldOccurrence.collecting_event_id
  )
)

function loadData() {
  TaxonDetermination.where({
    taxon_determination_object_id: [props.fieldOccurrence.id],
    taxon_determination_object_type: FIELD_OCCURRENCE
  }).then((response) => {
    determinations.value = response.body
  })

  Depiction.where({
    depiction_object_id: props.fieldOccurrence.id,
    depiction_object_type: FIELD_OCCURRENCE
  }).then(({ body }) => {
    depictions.value = body
  })
}

watch(isExpanded, loadData, {
  once: true
})
</script>
