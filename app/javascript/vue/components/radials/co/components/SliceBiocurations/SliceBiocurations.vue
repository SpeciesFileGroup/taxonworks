<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div class="flex-separate">
      <div>
        <h3>Add</h3>
        <BiocurationGroup
          v-for="group in biocurationsGroups"
          :key="group.id"
          :group="group"
          class="margin-small-bottom"
          color="submit"
          @select="addBiocuration"
        />
      </div>
    </div>

    <div class="margin-large-top">
      <template v-if="collectionObjects.passed.length">
        <h3>Passed</h3>
        <ul>
          <li
            v-for="id in collectionObjects.passed"
            :key="id"
          >
            <a
              :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`"
              v-html="id"
            />
          </li>
        </ul>
      </template>
      <template v-if="collectionObjects.failed.length">
        <h3>Failed</h3>
        <ul>
          <li
            v-for="item in collectionObjects.failed"
            :key="item"
          >
            <a
              :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${item}`"
              v-html="item"
            />
          </li>
        </ul>
      </template>
    </div>
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import {
  CollectionObject,
  ControlledVocabularyTerm,
  Tag
} from '@/routes/endpoints'
import { BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'
import BiocurationGroup from './BiocurationGroup.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

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
const biocurationsGroups = ref([])
const biocutarionsType = ref([])
const confirmationModalRef = ref(null)

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: [BIOCURATION_GROUP] }).then(
    (response) => {
      biocurationsGroups.value = response.body
      ControlledVocabularyTerm.where({ type: [BIOCURATION_CLASS] }).then(
        (response) => {
          biocutarionsType.value = response.body
          splitGroups()
        }
      )
    }
  )
})

function splitGroups() {
  biocurationsGroups.value.forEach((item, index) => {
    Tag.where({ keyword_id: item.id }).then(({ body }) => {
      const tmpArray = []

      body.forEach((item) => {
        biocutarionsType.value.forEach((itemClass) => {
          if (itemClass.id === item.tag_object_id) {
            tmpArray.push(itemClass)
          }
        })
      })

      item.list = tmpArray
    })
  })
}

async function addBiocuration(item) {
  const ok = await confirmationModalRef.value.show({
    title: 'Add biocurations',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'add',
    okButton: 'Add',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    const payload = {
      collection_object_query: props.parameters,
      collection_object: {
        biocuration_classifications_attributes: [
          { biocuration_class_id: item.id }
        ]
      }
    }

    CollectionObject.batchUpdate(payload).then(({ body }) => {
      Object.assign(collectionObjects.value, body)
      TW.workbench.alert.create(
        `${body.passed.length} sources were successfully added.`,
        'notice'
      )
    })
  }
}

async function removeBiocuration(item) {
  const ok = await confirmationModalRef.value.show({
    title: 'Remove biocurations',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'remove',
    okButton: 'Remove',
    cancelButton: 'Cancel',
    typeButton: 'delete'
  })

  if (ok) {
    const payload = {
      collection_object_query: props.parameters,
      collection_object: {
        biocuration_classifications_attributes: [
          {
            biocuration_class_id: item.id,
            _destroy: true
          }
        ]
      }
    }

    CollectionObject.batchUpdate(payload).then(({ body }) => {
      Object.assign(collectionObjects.value, body)
      TW.workbench.alert.create(
        `${body.passed.length} biocuration(s) were successfully removed.`,
        'notice'
      )
    })
  }
}
</script>
