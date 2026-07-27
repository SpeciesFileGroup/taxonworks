<template>
  <tr class="contextMenuCells">
    <td>
      <span v-html="biocurationGroup.object_tag" />
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
          icon
          variant="tonal"
          @click="emit('delete', biocurationGroup)"
        >
          <IconTrash class="w-4 h-4" />
        </v-btn>
      </div>
    </td>
  </tr>
</template>

<script setup>
import { computed } from 'vue'
import BiocurationModal from './BiocurationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import useStore from '../composables/useStore'
import makeTooltip from '../utils/makeTooltip.js'

const props = defineProps({
  biocurationGroup: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete'])
const { actions, getters } = useStore()

const biologicalGroupClasses = computed(() =>
  getters.getBiocurationTagsByGroupId(props.biocurationGroup.id)
)

const addBiocuration = (classId) =>
  actions.addBiocurationTag(props.biocurationGroup.id, classId)

const removeBiocuration = (classId) =>
  actions.removeBiocurationTag(props.biocurationGroup.id, classId)

const getBiologicalClassById = (id) =>
  getters.getBiocurationClasses().find((item) => item.id === id)
</script>
