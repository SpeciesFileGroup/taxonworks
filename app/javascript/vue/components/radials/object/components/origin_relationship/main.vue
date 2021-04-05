<template>
  <div>
    <div class="margin-medium-bottom">
      <div>
        <span
          v-if="originOf"
          v-html="originOf"/>
        <span v-else>Select a origin</span>
      </div>

      <div class="margin-medium-left inline">
        <span>is the origin of<br>
          <div class="margin-medium-left">
            <span
              v-if="originFor"
              v-html="originFor"/>
            <span v-else>[Select a origin]</span>
          </div>
        </span>
        <button
          class="center-icon small-icon button circle-button button-default"
          data-icon="w-swap"
          type="button"
          @click="flip = !flip">
          Flip
        </button>
      </div>
      <div class="margin-medium-left">
        <div class="margin-xlarge-left">
          a <select v-model="typeSelected">
            <option :value="undefined">
              Select type
            </option>
            <option
              v-for="(item, key) in typeList"
              :key="key"
              :value="key">
              {{ key }}
            </option>
          </select>
        </div>
      </div>
    </div>
    <smart-selector
      v-if="typeSelected"
      :model="modelSelected"
      :target="metadata.object_type"
      @selected="setObject"
    />

    <div>
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!objectSelected"
        @click="createOrigin">
        Create
      </button>
    </div>
    <table>
      <thead>
        <tr>
          <th>New object</th>
          <th>Old object</th>
          <th></th>
        </tr>
      </thead>
      <draggable
        class="table-entrys-list"
        element="tbody"
        v-model="list"
        @end="onSortable">
        <tr v-for="(item, index) in list">
          <td v-html="item.new_object_object_tag"/>
          <td v-html="item.old_object_object_tag"/>
          <span
            class="circle-button btn-delete"
            @click="removeOrigin(index)"/>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import CRUD from '../../request/crud'
import annotatorExtend from '../annotatorExtend'
import Draggable from 'vuedraggable'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    Draggable,
    SmartSelector
  },

  data () {
    return {
      objectSelected: undefined,
      originRelationship: undefined,
      flip: undefined,
      typeSelected: undefined
    }
  },

  computed: {
    typeList () {
      return this.metadata.endpoints.origin_relationships.origin_for
    },

    originOf () {
      return !this.flip ? this.metadata.object_tag : this.objectSelected?.object_tag
    },

    originFor () {
      return this.flip ? this.metadata.object_tag : this.objectSelected?.object_tag
    },

    modelSelected () {
      return this.typeList[this.typeSelected]
    }
  },

  methods: {
    setObject (item) {
      this.objectSelected = item
    },

    createOrigin () {
      const newObject = !this.flip ? this.objectSelected : { id: this.metadata.object_id, base_class: this.metadata.object_type }
      const oldObject = this.flip ? this.objectSelected : { id: this.metadata.object_id, base_class: this.metadata.object_type }
      const originRelationship = {
        old_object_id: oldObject.id,
        old_object_type: oldObject.base_class,
        new_object_id: newObject.id,
        new_object_type: newObject.base_class
      }

      this.create('/origin_relationships', { origin_relationship: originRelationship }).then(response => {
        this.list.unshift(response.body)
      })
    },

    removeOrigin (index) {
      this.destroy(`/origin_relationships/${this.list[index].id}.json`).then(({ body }) => {
        this.list.splice(index, 1)
      })
    },

    onSortable ({ newIndex }) {
      const originRelationship = {
        id: this.list[newIndex].id,
        position: newIndex
      }

      this.update(`/origin_relationships/${originRelationship.id}.json`, { origin_relationship: originRelationship }).then(({ body }) => {
        this.$set(this.list, newIndex, body)
      })
    }
  }
}
</script>
