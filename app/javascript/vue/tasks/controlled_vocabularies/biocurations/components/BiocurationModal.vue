<template>
  <div>
    <v-btn
      color="primary"
      icon
      variant="tonal"
      title="Add biocuration classes"
      @click="showModal = true"
    >
      <IconPlus class="w-4 h-4" />
    </v-btn>

    <v-modal
      v-if="showModal"
      @close="showModal = false"
    >
      <template #header>
        <h3>Add biocuration class to {{ groupName }}</h3>
      </template>
      <template #body>
        <div>
          <template
            v-for="item in biocurationClasses"
            :key="item.id"
          >
            <v-btn
              v-if="
                createdBiocurations.find(
                  (created) => created.tag_object_id === item.id
                )
              "
              class="margin-small"
              color="destroy"
              :title="makeTooltip(item)"
              @click="emit('delete', item.id)"
            >
              {{ item.object_label }}
            </v-btn>

            <v-btn
              v-else
              class="margin-small"
              color="create"
              :title="makeTooltip(item)"
              @click="emit('create', item.id)"
            >
              {{ item.object_label }}
            </v-btn>
          </template>
        </div>
      </template>
    </v-modal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import useStore from '../composables/useStore'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPlus from '@/components/Icon/IconPlus.vue'
import makeTooltip from '../utils/makeTooltip.js'

const { getters } = useStore()

const props = defineProps({
  groupName: {
    type: String,
    required: true
  },

  createdBiocurations: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['create', 'delete'])

const showModal = ref(false)
const biocurationClasses = computed(() => getters.getBiocurationClasses())
</script>
