<template>
  <table class="vue-table">
    <thead>
      <tr>
        <th>Relationship</th>
        <th>Related</th>
        <th>Citation</th>
        <th></th>
      </tr>
    </thead>
    <transition-group
      name="list-complete"
      tag="tbody"
    >
      <template
        v-for="(item, index) in renderList"
        :key="item.id"
      >
        <tr class="list-complete-item">
          <td v-html="item.relationship" />
          <td v-html="item.related" />
          <td v-html="item.citation" />
          <td>
            <div class="middle horizontal-right-content gap-small">
              <RadialAnnotator :global-id="item.globalId" />
              <VBtn
                circle
                color="primary"
                @click="() => emit('edit', list[index])"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <VBtn
                circle
                color="destroy"
                @click="() => deleteItem(list[index])"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </template>
    </transition-group>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['delete', 'edit'])

function deleteItem(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    emit('delete', item)
  }
}

const renderList = computed(() =>
  props.list.map((item) => ({
    id: item.id,
    globalId: item.globalId,
    relationship: getRelationshipString(item),
    related: item.related.object_tag,
    citation: item.citation.label
  }))
)

function getRelationshipString(item) {
  return item.relationship.name || item.relationship.object_label
}
</script>
<style lang="scss" scoped>
.vue-table {
  width: 100%;
  .vue-table-options {
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
  }
  tr {
    cursor: default;
  }
}

.list-complete-item {
  justify-content: space-between;
  transition: all 0.5s, opacity 0.2s;
}

.list-complete-enter-active,
.list-complete-leave-active {
  opacity: 0;
  font-size: 0px;
  border: none;
}
</style>
