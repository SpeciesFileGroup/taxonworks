<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Geographic area</th>
          <th>Type</th>
          <th>Parent</th>
          <th />
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
          <td>
            <span
              :class="{ absent: item.is_absent }"
              v-html="item.geographic_area.name"
            />
          </td>
          <td>
            <span> {{ item.geographic_area.geographic_area_type.name }} </span>
          </td>
          <td>
            <span> {{ item.geographic_area.parent.name }} </span>
          </td>
          <td>
            <div class="horizontal-right-content gap-xsmall">
              <CitationCount
                :object="item"
                :values="item.citations"
                target="asserted_distributions"
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

defineProps({
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
    this.$emit('delete', item)
  }
}
</script>
<style lang="scss" scoped>
.vue-table-container {
  padding: 0px;
  position: relative;
}

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
.absent {
  padding: 5px;
  border-radius: 3px;
  background-color: #000;
  color: #fff;
}
</style>
