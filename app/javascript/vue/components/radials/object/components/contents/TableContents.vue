<template>
  <table class="table-striped table-cells-border">
    <thead>
      <tr>
        <th>Text</th>
        <th>Topic</th>
        <th class="w-2">Published</th>
        <th class="w-2"></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in contents"
        :key="item.id"
      >
        <td v-html="shorten(item.text, 150)"></td>
        <td v-html="item.topic.name"></td>
        <td>
          <PublishContent :content-id="item.id" />
        </td>
        <td>
          <div class="flex-row gap-small">
            <RadialAnnotator :global-id="item.global_id" />
            <VBtn
              circle
              color="primary"
              @click="() => emit('edit', item)"
            >
              <VIcon
                name="pencil"
                x-small
              />
            </VBtn>
            <VBtn
              circle
              color="destroy"
              @click="() => emitDelete(item)"
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
import { shorten } from '@/helpers'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import PublishContent from '@/tasks/contents/editor/editor/PublishContent.vue'

const props = defineProps({
  contents: {
    type: Array,
    required: true
  }
})

const emit = defineEmits('edit', 'delete')

function emitDelete(item) {
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure want to proceed?`
    )
  ) {
    emit('delete', item)
  }
}
</script>
