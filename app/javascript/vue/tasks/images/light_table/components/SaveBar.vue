<template>
  <div class="panel content margin-medium-bottom">
    <div class="horizontal-left-content middle gap-small">
      <input
        v-if="store.isNew"
        v-model="store.draftName"
        type="text"
        class="light-table-save-bar__name-input"
        placeholder="Name this light table to save it"
        aria-label="Light table name"
      />
      <template v-else-if="isEditing">
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
          v-if="store.isNew"
          class="text-xs light-table-save-bar__saved"
        >
          Not saved yet
        </span>
        <span
          v-else-if="store.hasChanges"
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
          :disabled="!store.canSave"
          @click="store.save()"
        >
          {{ store.isSaving ? 'Saving...' : 'Save' }}
        </VBtn>
        <VBtn
          color="primary"
          variant="outline"
          medium
          @click="emit('open')"
        >
          Open light table
        </VBtn>
        <VBtn
          color="primary"
          variant="outline"
          medium
          :disabled="store.isNew && !store.hasChanges"
          @click="emit('new')"
        >
          New light table
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

const emit = defineEmits(['open', 'new'])

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

.light-table-save-bar__name-input {
  min-width: 260px;
}

.light-table-save-bar__saved {
  color: var(--text-muted-color);
}
</style>
