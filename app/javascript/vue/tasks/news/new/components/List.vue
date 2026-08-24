<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>Title</th>
        <th>Body</th>
        <th>Type</th>
        <th v-if="project">Public</th>
        <th>Start</th>
        <th>End</th>
        <th class="w-2" />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
      >
        <td v-html="item.title" />
        <td>
          <div
            class="news-body"
            v-html="item.bodyHtml"
          />
        </td>
        <td>
          <VBadge
            class="capitalize"
            :color="newsColors[item.type.split('::')[2]]"
          >
            {{ getTypeLabel(item) }}
          </VBadge>
        </td>
        <td v-if="project">
          <input
            type="checkbox"
            :checked="item.isPublic"
            :disabled="!isPublishable(item)"
            :title="
              isPublishable(item) ? undefined : 'Only blog posts can be public'
            "
            @change="
              (e) => emit('update:public', { item, isPublic: e.target.checked })
            "
          />
        </td>
        <td class="line-nowrap">
          {{ formatDate(item.start) }}
        </td>
        <td class="line-nowrap">
          {{ formatDate(item.end) }}
        </td>
        <td>
          <div class="flex-row gap-small">
            <VBtn
              color="primary"
              icon
              variant="tonal"
              @click="() => emit('edit', item)"
            >
              <IconPencil class="w-4 h-4" />
            </VBtn>
            <VBtn
              color="destroy"
              icon
              variant="tonal"
              @click="() => selectItem(item)"
            >
              <IconTrash class="w-4 h-4" />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPencil from '@/components/Icon/IconPencil.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import newsColors from '@/tasks/news/browse/constants/newsColors.js'
import { NEWS_PROJECT_BLOGPOST } from '@/constants/news'

defineProps({
  list: {
    type: Array,
    required: true
  },

  project: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['remove', 'update:public'])

function selectItem(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure you want to proceed?"
    )
  ) {
    emit('remove', item)
  }
}

function isPublishable(item) {
  return item.type === NEWS_PROJECT_BLOGPOST
}

function getTypeLabel(item) {
  return item.type.split('::').pop()
}

function formatDate(date) {
  return date ? date.replace('T', ' ') : date
}
</script>

<style scoped>
.news-body {
  max-width: 500px;
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
  opacity: 0.75;
}

.news-body * {
  display: inline;
  white-space: nowrap !important;
  font-size: inherit;
  line-height: inherit;
  font-weight: inherit;
}
</style>
