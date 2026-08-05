<template>
  <table class="vue-table">
    <thead>
      <tr>
        <th>Relationship</th>
        <th>Related</th>
        <th>Citation</th>
        <th>
          <div class="horizontal-right-content">
            <VLock v-model="lock" />
          </div>
        </th>
      </tr>
    </thead>
    <transition-group
      name="list-complete"
      tag="tbody"
    >
      <template
        v-for="item in renderList"
        :key="item.uuid"
      >
        <tr class="list-complete-item">
          <td v-html="item.relationship" />
          <td v-html="item.related" />
          <td v-html="item.citation" />
          <td>
            <div class="middle horizontal-right-content gap-small">
              <RadialAnnotator
                v-if="item.globalId"
                :global-id="item.globalId"
              />
              <VBtn
                icon
                variant="tonal"
                :color="item.id ? 'destroy' : 'primary'"
                @click="() => deleteItem(item)"
              >
                <IconTrash class="w-4 h-4" />
              </VBtn>
            </div>
          </td>
        </tr>
      </template>
    </transition-group>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VLock from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import { computed } from 'vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const lock = defineModel('lock', {
  type: Boolean,
  default: false
})

const emit = defineEmits(['delete'])

const renderList = computed(() =>
  props.list.map((item) => ({
    id: item.id,
    uuid: item.uuid,
    globalId: item.globalId,
    relationship: getRelationshipString(item),
    related: item.related.object_tag,
    citation: item.citation.label
  }))
)

function deleteItem(item) {
  if (item.id) {
    if (
      window.confirm(
        "You're trying to delete this record. Are you sure you want to proceed?"
      )
    ) {
      emit('delete', item)
    }
  } else {
    emit('delete', item)
  }
}

function getRelationshipString(item) {
  return item.relationship.name || item.relationship.object_label
}
</script>
