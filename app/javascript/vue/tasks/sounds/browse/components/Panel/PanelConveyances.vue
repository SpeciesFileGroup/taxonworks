<template>
  <div class="panel content">
    <h3>Conveyances ({{ conveyances.length }})</h3>

    <table
      v-if="conveyances.length"
      class="full_width table-striped"
    >
      <thead>
        <tr>
          <th class="region-cell">Conveyed object</th>
          <th class="w-3">Type</th>
          <th class="w-3">Fragment</th>
          <th class="w-2" />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="conveyance in conveyances"
          :key="conveyance.id"
        >
          <td
            class="region-cell"
            :style="regionSwatchFor(conveyance)"
          >
            <a
              v-if="browseUrlFor(conveyance)"
              :href="browseUrlFor(conveyance)"
              v-html="objectTagFor(conveyance)"
            />
            <span
              v-else
              v-html="objectTagFor(conveyance)"
            />
          </td>
          <td>{{ humanize(conveyance.conveyance_object_type) }}</td>
          <td>
            <span v-if="fragmentFor(conveyance)">
              {{ fragmentFor(conveyance) }}
            </span>
            <span
              v-else
              class="text-muted-color"
            >
              Full track
            </span>
          </td>
          <td>
            <VBtn
              v-if="fragmentFor(conveyance)"
              icon
              variant="tonal"
              color="primary"
              title="Play this fragment"
              @click="
                () =>
                  emit('play', {
                    start: conveyance.start_time,
                    end: conveyance.end_time
                  })
              "
            >
              <IconPlay class="w-4 h-4" />
            </VBtn>
          </td>
        </tr>
      </tbody>
    </table>

    <p
      v-else
      class="text-muted-color"
    >
      This sound is not conveying any object yet.
    </p>
  </div>
</template>

<script setup>
import { makeBrowseUrl, secondsToTimeString } from '@/helpers'
import {
  ANATOMICAL_PART,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
} from '@/constants'
import { regionColorFor } from '../../utils/regionColors.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPlay from '@/components/Icon/IconPlay.vue'

const BROWSABLE_TYPES = [
  ANATOMICAL_PART,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
]

const props = defineProps({
  conveyances: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['play'])

function regionSwatchFor({ id }) {
  const color = regionColorFor(props.conveyances, id)

  return { borderLeftColor: color || 'transparent' }
}

function fragmentFor({ start_time, end_time }) {
  return start_time != null && end_time != null
    ? `${secondsToTimeString(start_time)} ${secondsToTimeString(end_time)}`
    : null
}

function objectTagFor({ conveyance_object, object_tag }) {
  return conveyance_object?.object_tag || object_tag
}

function browseUrlFor({ conveyance_object_id, conveyance_object_type }) {
  return BROWSABLE_TYPES.includes(conveyance_object_type)
    ? makeBrowseUrl({ id: conveyance_object_id, type: conveyance_object_type })
    : null
}

function humanize(type) {
  return type.replace(/([a-z])([A-Z])/g, '$1 $2')
}
</script>

<style scoped>
.region-cell {
  border-left: 4px solid transparent;
}
</style>
