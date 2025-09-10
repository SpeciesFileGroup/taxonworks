<template>
  <div>
    <h2>Properties</h2>
    <new-property
      @save="addProperty"
      ref="property"
    />
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
        </tr>
      </thead>
      <draggable
        v-model="list"
        tag="tbody"
        :group="{ name: 'property', pull: 'clone', put: false }"
        item-key="id"
        @start="drag = true"
        @end="drag = false"
      >
        <template #item="{ element }">
          <tr>
            <td>
              <div class="middle">
                <span
                  @click="editProperty(element)"
                  class="button button-circle btn-edit"
                />
                <span
                  class="margin-small-left cursor-grab"
                  v-html="element.object_tag"
                />
              </div>
            </td>
          </tr>
        </template>
      </draggable>
    </table>
  </div>
</template>

<script setup>
import Draggable from 'vuedraggable'
import NewProperty from './NewProperty'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { ref, useTemplateRef, onMounted } from 'vue'
import { addToArray } from '@/helpers'

const list = ref([])
const drag = ref(false)
const propertyRef = useTemplateRef('property')

onMounted(() => {
  ControlledVocabularyTerm.where({ type: ['BiologicalProperty'] }).then(
    ({ body }) => {
      list.value = body
    }
  )
})

function addProperty(property) {
  addToArray(list.value, property, { prepend: true })
}

function editProperty(property) {
  propertyRef.value.setProperty(property)
}
</script>
