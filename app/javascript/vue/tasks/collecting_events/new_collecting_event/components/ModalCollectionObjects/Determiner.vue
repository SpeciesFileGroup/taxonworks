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
            <span
              class="circle-button btn-delete"
              :class="{ 'button-default': !element.id }"
              @click="removeTaxonDetermination(index)"
            />
          </div>
        </li>
      </template>
    </VDraggable>
  </div>
</template>

<script setup>
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import VDraggable from 'vuedraggable'

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
