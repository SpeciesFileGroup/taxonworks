<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <div class="option_set_center">

    <VBtn
      v-if="store.lead.parent_id"
      color="primary"
      medium
      @click="previousOptionSet"
    >
      Go to the previous options
    </VBtn>

    <VBtn
      v-else
      color="update"
      medium
      @click="insertCouplet"
    >
      Insert a new initial couplet for the key
    </VBtn>

    <VBtn
      color="update"
      medium
      @click="() => { insertKeyModalIsVisible = true }"
    >
      Insert a key
    </VBtn>
  </div>

  <div v-if="hasChildren">
    <div class="option_set_center">
      <label>Options number from citation: </label>
      <input
        v-model="store.lead.origin_label"
        type="text"
        class="normal-input"
        size="3"
      />
    </div>
    <div class="option_set_horizontal_buttons">
      <div>
        <VBtn
          color="update"
          medium
          @click="saveChanges"
        >
          Update
        </VBtn>

        <VBtn
          color="update"
          medium
          @click="addLead"
        >
          Add a lead
        </VBtn>
      </div>

      <VBtn
        v-if="allowDestroyOptionSet"
        color="destroy"
        medium
        @click="destroyOptionSet"
      >
        Delete these options
      </VBtn>

      <VBtn
        v-else-if="allowDeleteOptionSet"
        color="destroy"
        medium
        @click="deleteOptionSet"
      >
        Delete these options and reparent the children
      </VBtn>

      <VBtn
        v-else
        color="destroy"
        disabled
        medium
      >
        Can't delete when more than one side has children
      </VBtn>
    </div>

    <div class="left_and_right_option_set">
      <Lead
        v-for="(child, i) in store.children"
        :key="child.id"
        :position="i"
        :redirect-options="redirectOptions"
        @editing-has-occurred="() => emit('editingHasOccurred')"
      />
    </div>
  </div>

  <div v-else class="option_set_center">
    <p>No remaining choices.</p>
    <VBtn
      color="update"
      medium
      @click="nextCouplet"
    >
      Create the next list of options
    </VBtn>
  </div>

  <InsertKeyModal
    v-if="insertKeyModalIsVisible"
    @close="() => { insertKeyModalIsVisible = false }"
    @keySelected="
      (id) => {
        insertKeyModalIsVisible = false
        insertKey(id)
      }"
    :container-style="{ width: '600px' }"
  />
</template>

<script setup>
import InsertKeyModal from './InsertKeyModal.vue'
import Lead from './Lead.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { computed, ref, watch } from 'vue'
import { Lead as LeadEndpoint } from '@/routes/endpoints'
import { useInsertCouplet } from './composables/useInsertCouplet.js'
import { useStore } from '../store/useStore.js'

const emit = defineEmits(['editingHasOccurred'])

const store = useStore()

const loading = ref(false)
const insertKeyModalIsVisible = ref(false)

const hasChildren = computed(() => {
  return store.children.length >= 2 &&
    (store.children[0].id && store.children[1].id)
})

const allowDestroyOptionSet = computed(() => {
  if (!store.lead.parent_id) {
    return false
  }

  return store.children.every((child, i) => {
    return !childHasChildren(child, i)
  })
})

const allowDeleteOptionSet = computed(() => {
  let childWithChildrenCount = 0
  return store.children.every((child, i) => {
    if (childHasChildren(child, i)) {
      childWithChildrenCount++
    }

    return childWithChildrenCount <= 1
  })
})

const redirectOptions = ref([])

function loadRedirectOptions() {
  LeadEndpoint.redirect_option_texts(store.lead.id).then(({ body }) => {
    const texts = body.redirect_option_texts.flatMap((o) => {
      if (store.children.some((child) => {
          // Don't allow redirect to a sibling
          child.id == o.id
        }) || o.id == store.lead.id
      ) {
        return []
      }

      let id_label = o.label ? ('[' + o.label + ']') : ''
      id_label = id_label + '[tw:' + o.id + ']'
      return [{
        id: o.id,
        text: id_label + ' ' + (o.text || '(No text)')
      }]
    })
    redirectOptions.value = texts
  })
}

watch(
  () => store.lead.id,
  () => loadRedirectOptions(),
  { immediate: true }
)

function previousOptionSet() {
  if (store.dataChangedSinceLastSave() &&
    !window.confirm(
      'You have unsaved data, are you sure you want to navigate to a new couplet?'
    )
  ) {
    return
  }

  store.loadKey(store.lead.parent_id)
  emit('editingHasOccurred')
}

function insertCouplet() {
  useInsertCouplet(store.lead.id, loading, store, () => {
    store.loadKey(store.lead.id)
      TW.workbench.alert.create(
        "Success - you're now editing the inserted couplet",
        'notice'
      )
      emit('editingHasOccurred')
  })
}

function insertKey(keyId) {
  const payload = {
    key_to_insert: keyId
  }

  loading.value = true
  LeadEndpoint.insert_key(store.lead.id, payload)
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create("Inserted key - the root lead of the inserted key is now visible here", 'notice')
      emit('editingHasOccurred')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function saveChanges() {
  const leadOriginLabelChanged = store.originLabelChangedSinceLastSave()
  const childrenToUpdate = store.childrenChangedSinceLastSaveList()
  if (!leadOriginLabelChanged && childrenToUpdate.length == 0) {
    TW.workbench.alert.create('No new changes to save.', 'notice')
    return
  }

  const promises = childrenToUpdate.map((lead) => {
    const payload = {
      lead
    }

    return LeadEndpoint.update(lead.id, payload)
      .then(({ body }) => {
        // Future changes when redirect changes.
        store.updateChild(body.lead, body.future)
        emit('editingHasOccurred')
      })
      // TODO: if multiple fail we can get overlapping popup messages, but is
      // there a way to catch here without also displaying the error message (so
      // that we can instead combine error messages in allSettled)?
      .catch(() => {})
  })

  if (leadOriginLabelChanged) {
    const payload = {
      lead: store.lead
    }

    promises.push(
      LeadEndpoint.update(store.lead.id, payload)
        .then(() => {
          store.last_saved.origin_label = store.lead.origin_label
          emit('editingHasOccurred')
        })
        .catch(() => {})
    )
  }

  loading.value = true
  Promise.allSettled(promises)
    .then((results) => {
      if (results.every((r) => r.status == 'fulfilled')) {
        TW.workbench.alert.create('Options were successfully saved.', 'notice')
      }
    })
    .finally(() => {
      loading.value = false
    })
}

function nextCouplet() {
  loading.value = true
  LeadEndpoint.create_for_edit(store.lead.id)
    .then(({ body }) => {
      store.loadKey(body)
      emit('editingHasOccurred')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function addLead() {
  loading.value = true
  LeadEndpoint.add_lead(store.lead.id)
    .then(({ body }) => {
      store.addLead(body)
      TW.workbench.alert.create('Added a new lead.', 'notice')
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
}

function destroyOptionSet() {
  if (window.confirm(
    'Delete all options for this stage of the key?'
  )) {
    loading.value = true
    LeadEndpoint.destroy_children(store.lead.id)
      .then(() => {
        store.loadKey(store.lead.id)
        TW.workbench.alert.create('Option set was successfully deleted.', 'notice')
        emit('editingHasOccurred')
      })
      .catch(() => {})
      .finally(() => {
        loading.value = false
      })
  }
}

function deleteOptionSet() {
  if (window.confirm(
    'Delete all options at this level of the key and re-attach orphaned children?'
  )) {
    loading.value = true
    LeadEndpoint.delete_children(store.lead.id)
      .then(() => {
        store.loadKey(store.lead.id)
        TW.workbench.alert.create('Option set was successfully deleted.', 'notice')
        emit('editingHasOccurred')
      })
      .catch(() => {})
      .finally(() => {
        loading.value = false
      })
  }
}

// i is the position of child.
// !! Redirects **do** count as a child here (they contribute to futures).
function childHasChildren(child, i) {
  return !!child?.id && store.futures[i].length > 0
}
</script>

<style lang="scss" scoped>
.left_and_right_option_set {
  display: flex;
  justify-content: space-around;
  flex-wrap: wrap;
  gap: 2em;
}
.option_set_center {
  margin-top: 1em;
  margin-bottom: 1em;
  text-align: center;
}
.option_set_center button {
  margin-right: 2em;
}
.option_set_horizontal_buttons {
  display: grid;
  grid-template-columns: 50% 50%;
  column-gap: 0px;
  justify-items: start;
  margin-bottom: 2em;
  margin-top: 2em;
  :first-child {
    justify-self: end;
    margin-right: 2em;
  }
  :last-child {
    margin-left: 2em;
  }
}
.title_and_annotator {
  margin-top: 1em;
  span {
    display: inline-block;
  }
  // The radial annotator icon
  div {
    vertical-align: 6px;
    display: inline-block;
    margin-left: .5em;
  }
}
</style>