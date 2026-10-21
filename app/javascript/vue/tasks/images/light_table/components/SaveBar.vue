<template>
  <div class="panel content margin-medium-bottom">
    <div class="horizontal-left-content middle gap-small">
      <template v-if="isEditing">
        <input
          v-model="nameDraft"
          type="text"
          @keydown.enter.prevent="saveName"
          @keydown.escape.prevent="isEditing = false"
        />
        <VBtn
          color="update"
          medium
          :disabled="!nameDraft.trim()"
          @click="saveName"
        >
          Update
        </VBtn>
        <VBtn
          color="primary"
          variant="outline"
          medium
          @click="isEditing = false"
        >
          Cancel
        </VBtn>
      </template>
      <template v-else>
        <h3 class="light-table-save-bar__name">{{ store.composition.name }}</h3>
        <VBtn
          circle
          color="primary"
          title="Rename"
          @click="startEdit"
        >
          <VIcon
            name="pencil"
            x-small
          />
        </VBtn>
        <RadialNavigator
          v-if="store.composition.global_id"
          :global-id="store.composition.global_id"
        />
      </template>

      <div class="horizontal-right-content middle gap-small full_width">
        <span
          v-if="store.hasChanges"
          class="text-xs"
        >
          {{ store.changeCount }} unsaved change(s)
        </span>
        <span
          v-else
          class="text-xs light-table-save-bar__saved"
        >
          All changes saved
        </span>
        <VBtn
          color="create"
          medium
          :disabled="!store.hasChanges || store.isSaving"
          @click="store.save()"
        >
          {{ store.isSaving ? 'Saving...' : 'Save' }}
        </VBtn>
        <VBtn
          color="primary"
          variant="outline"
          medium
          @click="emit('close')"
        >
          Change light table
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import useStore from '../store/store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

const emit = defineEmits(['close'])

const store = useStore()
const isEditing = ref(false)
const nameDraft = ref('')

function startEdit() {
  nameDraft.value = store.composition.name
  isEditing.value = true
}

function saveName() {
  store
    .updateComposition({ name: nameDraft.value.trim() })
    .then(() => {
      isEditing.value = false
    })
    .catch(() => {})
}
</script>

<style scoped>
.light-table-save-bar__name {
  margin: 0;
  white-space: nowrap;
}

.light-table-save-bar__saved {
  color: var(--text-muted-color);
}
</style>
