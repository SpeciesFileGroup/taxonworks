<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>Title</th>
        <th>Body</th>
        <th>Type</th>
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
        <td
          class="line-nowrap"
          v-text="item.start"
        />
        <td
          class="line-nowrap"
          v-text="item.end"
        />
        <td>
          <div class="flex-row gap-small">
            <VBtn
              color="primary"
              circle
              @click="() => emit('edit', item)"
            >
              <VIcon
                name="pencil"
                x-small
              />
            </VBtn>
            <VBtn
              color="destroy"
              circle
              @click="() => selectItem(item)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import newsColors from '@/tasks/news/browse/constants/newsColors.js'

defineProps({
  list: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['remove'])

function selectItem(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    emit('remove', item)
  }
}

function getTypeLabel(item) {
  return item.type.split('::').pop()
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
}
</style>
