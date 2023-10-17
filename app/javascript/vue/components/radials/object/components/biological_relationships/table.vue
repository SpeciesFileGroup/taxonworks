<template>
  <div>
    <table class="vue-table">
      <thead>
        <tr>
          <th>Relationship</th>
          <th>Related</th>
          <th>Inverted</th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item"
        >
          <td v-html="item.biological_relationship.object_tag" />
          <td v-html="getSubjectOrObject(item)" />
          <td>
            {{ item.biological_association_object_id === metadata.object_id }}
          </td>
          <td>
            <div class="horizontal-right-content gap-xsmall">
              <citation-count
                :object="item"
                :values="item.citations"
                target="biological_associations"
              />
              <RadialAnnotator :global-id="item.global_id" />
              <VBtn
                circle
                color="update"
                @click="emit('edit', Object.assign({}, item))"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>

              <VBtn
                circle
                :color="softDelete ? 'primary' : 'destroy'"
                @click="deleteItem(item, index)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import CitationCount from '../shared/citationsCount.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },
  metadata: {
    type: Object,
    required: true
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

function getSubjectOrObject(item) {
  return item.biological_association_object_id === props.metadata.object_id
    ? item.subject.object_tag
    : item.object.object_tag
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
