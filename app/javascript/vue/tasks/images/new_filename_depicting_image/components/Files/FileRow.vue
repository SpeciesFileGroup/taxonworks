<template>
  <tr>
    <td>
      <img
        v-if="!thumbnailError"
        class="file-row-thumbnail"
        :src="row.thumbnail"
        :alt="row.filename"
        loading="lazy"
        @error="thumbnailError = true"
      />
      <VIcon
        v-else
        name="image"
        title="No preview available"
      />
    </td>
    <td class="file-row-filename">{{ row.filename }}</td>
    <td>{{ match?.identifier }}</td>
    <td>
      <div
        v-if="match?.collection_object_id"
        class="horizontal-left-content middle gap-small"
      >
        <a
          :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${match.collection_object_id}`"
          target="_blank"
        >
          {{ match.collection_object_id }}
        </a>
        <RadialAnnotator
          v-if="match.global_id"
          :global-id="match.global_id"
        />
      </div>
    </td>
    <td>{{ match?.figure_label }}</td>
    <td>{{ match?.caption }}</td>
    <td>
      <div class="flex-col gap-xsmall">
        <VBadge
          class="file-row-status"
          :color="STATUS_META[status].color"
          :title="STATUS_DESCRIPTIONS[status]"
        >
          {{ STATUS_META[status].label }}
        </VBadge>
        <span v-if="row.upload?.message">{{ row.upload.message }}</span>
      </div>
    </td>
    <td class="w-2">
      <VBtn
        v-if="isRemovable"
        circle
        color="primary"
        title="Remove file"
        @click="emit('remove', row)"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </td>
  </tr>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from '../../store/store'
import { STATUS, STATUS_DESCRIPTIONS, STATUS_META } from '../../constants'
import { RouteNames } from '@/routes/routes'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  row: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['remove'])

const store = useStore()

const thumbnailError = ref(false)

const status = computed(() => store.rowStatus(props.row))

const match = computed(() => store.rowMatch(props.row))

const isRemovable = computed(
  () => ![STATUS.Queued, STATUS.Uploading].includes(status.value)
)
</script>

<style scoped>
.file-row-thumbnail {
  width: 48px;
  height: 48px;
  object-fit: cover;
}

.file-row-filename {
  word-break: break-all;
}

.file-row-status {
  width: max-content;
}
</style>
