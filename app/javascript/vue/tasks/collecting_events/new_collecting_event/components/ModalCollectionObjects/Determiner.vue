<template>
  <div>
    <h3>Determinations</h3>
    <TaxonDeterminationForm @onAdd="addDetermination" />
    <VDraggable
      class="table-entrys-list"
      element="ul"
      v-model="list"
      @end="updatePosition"
    >
      <template #item="{ element, index }">
        <li class="list-complete-item flex-separate middle">
          <span v-html="element.object_tag" />
          <div class="horizontal-left-content">
            <VBtn
              icon
              color="primary"
              variant="tonal"
              title="Remove determination"
              @click="removeTaxonDetermination(index)"
            >
              <IconTrash class="w-4 h-4" />
            </VBtn>
          </div>
        </li>
      </template>
    </VDraggable>
  </div>
</template>

<script setup>
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import VDraggable from 'vuedraggable'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

const emit = defineEmits(['update:modelValue'])

const list = defineModel({
  type: Array,
  required: true
})

function addDetermination(taxonDetermination) {
  list.value.push(taxonDetermination)
}

function updatePosition() {
  list.value.forEach((item, index) => {
    item.position = index + 1
  })
}

function removeTaxonDetermination(index) {
  list.value.splice(index, 1)
}
</script>
