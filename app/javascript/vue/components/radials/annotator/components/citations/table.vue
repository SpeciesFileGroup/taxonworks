<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Citation</th>
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
              :class="{ originalCitation: item.is_original }"
              class="margin-small-right"
              v-html="item.object_tag"
            />
            <SoftValidation :global-id="item.global_id" />
          </td>
          <td>
            <div class="horizontal-right-content middle gap-small">
              <a
                class="button-default circle-button btn-citation"
                :href="`/tasks/nomenclature/by_source?source_id=${item.source_id}`"
                target="blank"
              />
              <PdfButton
                v-if="item.hasOwnProperty('target_document')"
                :pdf="item.target_document"
              />
              <RadialAnnotator :global-id="item.global_id" />
              <VBtn
                circle
                color="update"
                @click="$emit('edit', Object.assign({}, item))"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>

              <VBtn
                circle
                color="destroy"
                @click="deleteItem(item)"
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
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import PdfButton from '@/components/pdfButton.vue'
import SoftValidation from '@/components/soft_validations/objectValidation'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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
    emit('delete', item)
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
.originalCitation {
  padding: 5px;
  border-radius: 3px;
  background-color: #006ebf;
  color: #fff;
}
</style>
