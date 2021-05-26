<template>
  <div>
    <slot
      name="options"
      :item="item"/>
    <radial-annotator
      v-if="annotator"
      :global-id="item.global_id"/>
    <radial-object
      v-if="radialObject && item.hasOwnProperty('global_id')"
      :global-id="item.global_id"/>
    <span
      v-if="edit"
      class="circle-button btn-edit"
      @click="$emit('edit', item)">Edit
    </span>
    <span
      v-if="remove"
      class="circle-button btn-delete"
      :class="{ 'button-default': softDelete }"
      @click="deleteItem(item, index)">Remove
    </span>
  </div>
</template>

<script>

import { RadialAnnotator } from 'components/radials/annotator/annotator'
import { RadialObject } from 'components/radials/object/radial'

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },

  props: {
    item: {
      type: Object,
      required: true
    }
  }
}
</script>
