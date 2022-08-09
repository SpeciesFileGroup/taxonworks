<template>
  <div>
    <h3>Determinations</h3>
    <taxon-determination-form @onAdd="addDetermination"/>
    <draggable
      class="table-entrys-list"
      element="ul"
      v-model="list"
      @end="updatePosition">
      <template #item="{ element, index }">
        <li class="list-complete-item flex-separate middle">
          <span v-html="element.object_tag"/>
          <div class="horizontal-left-content">
            <span
              class="circle-button btn-delete"
              :class="{ 'button-default': !element.id }"
              @click="removeTaxonDetermination(index)"/>
          </div>
        </li>
      </template>
    </draggable>
  </div>
</template>

<script>

import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import Draggable from 'vuedraggable'


export default {
  components: {
    Draggable,
    TaxonDeterminationForm
  },

  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    list: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    addDetermination (taxonDetermination) {
      this.list.push(taxonDetermination)
    },

    updatePosition () {
      for (let i = 0; i < this.list.length; i++) {
        this.list[i].position = (i + 1)
      }
    },

    removeTaxonDetermination (index) {
      this.list.splice(index, 1)
    }
  }
}
</script>
