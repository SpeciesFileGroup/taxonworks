<template>
  <tr class="contextMenuCells">
    <td>
      <span v-html="biocurationGroup.object_tag"/>
    </td>
    <td>
      <v-btn
        v-for="item in biologicalGroupClasses"
        :key="item.id"
        class="margin-small"
        color="destroy"
        :title="makeTooltip(getBiologicalClassById(item.tag_object_id))"
        @click="removeBiocuration(item.tag_object_id)"
      >
        {{ item.annotated_object.object_label }}
      </v-btn>
    </td>
    <td>
      <div class="horizontal-right-content">
        <BiocurationModal
          class="margin-small-right"
          :group-name="biocurationGroup.name"
          :created-biocurations="biologicalGroupClasses"
          @create="addBiocuration"
          @delete="removeBiocuration"
        />
        <v-btn
          color="destroy"
          circle
          @click="emit('delete', biocurationGroup)"
        >
          <v-icon
            color="white"
            name="trash"
            x-small
          />
        </v-btn>
      </div>
    </td>
  </tr>
</template>

<script setup>

import useBiocurationGroup from '../composables/useBiocurationGroup.js'
import BiocurationModal from './BiocurationModal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import useStore from '../composables/useStore'
import makeTooltip from '../utils/makeTooltip.js'

const props = defineProps({
  biocurationGroup: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete'])
const { getters } = useStore()

const {
  biologicalGroupClasses,
  addBiocuration,
  removeBiocuration
} = useBiocurationGroup(props.biocurationGroup.id)

const getBiologicalClassById = id => getters.getBiocurationClasses().find(item => item.id === id)

</script>
