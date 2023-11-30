<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <fieldset>
      <legend>Repository</legend>
      <SmartSelector
        model="repositories"
        :target="COLLECTION_OBJECT"
        :klass="COLLECTION_OBJECT"
        @selected="(item) => (repository = item)"
      />
      <SmartSelectorItem
        :item="repository"
        @unset="repository = undefined"
      />
    </fieldset>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!repository"
      @click="handleUpdate"
    >
      Update
    </VBtn>

    <div class="margin-large-top">
      <template v-if="collectionObjects.passed.length">
        <h3>Updated</h3>
        <ul>
          <li
            v-for="item in collectionObjects.passed"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
      <template v-if="collectionObjects.failed.length">
        <h3>Not updated</h3>
        <ul>
          <li
            v-for="item in collectionObjects.failed"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
    </div>
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import { CollectionObject } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const MAX_LIMIT = 50

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const collectionObjects = ref({ passed: [], failed: [] })
const repository = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const confirmationModalRef = ref(null)

function changeRepository() {
  const payload = {
    collection_object_query: props.parameters,
    collection_object: {
      repository_id: repository.value.id
    }
  }

  CollectionObject.batchUpdate(payload).then(({ body }) => {
    TW.workbench.alert.create(
      `${body.passed.length} collection object(s) were successfully added.`,
      'notice'
    )
  })
}

async function handleUpdate() {
  const ok = await confirmationModalRef.value.show({
    title: 'Change repository',
    message:
      'This will change the collection object repository. Are you sure you want to proceed?',
    confirmationWord: 'CHANGE',
    okButton: 'Update',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    changeRepository()
  }
}
</script>
