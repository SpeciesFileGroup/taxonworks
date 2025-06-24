<template>
  <table class="vue-table table-striped">
    <thead>
      <tr>
        <th>Total</th>
        <th class="lock-biocuration"></th>
        <th>Biocurations</th>
        <th></th>
      </tr>
    </thead>
    <tbody class="list-complete">
      <tr class="list-complete-item highlight">
        <td>
          <input
            v-if="!collectionObject.id"
            :data-index="0"
            type="number"
            class="total-size co-total-count"
            min="1"
            v-model="collectionObject.total"
          />
          <input
            v-else
            :data-index="0"
            class="total-size co-total-count"
            type="number"
            v-model="collectionObject.total"
            @change="updateCO(collectionObject)"
          />
        </td>
        <td class="lock-biocuration">
          <VLock v-model="locked.biocuration" />
        </td>
        <td>
          <FormBiocuration
            v-model="biocurationStore.list"
            :biocurations-groups="biocurationStore.biocurationGroups"
            @add="biocurationStore.add"
            @remove="biocurationStore.remove"
          />
        </td>
        <td>
          <div
            v-if="collectionObject.id"
            class="horizontal-right-content gap-small"
          >
            <AccessionMetadata :collection-object="collectionObject" />
            <RadialAnnotator :global-id="collectionObject.global_id" />
            <VBtn
              circle
              color="create"
              disabled
            >
              <VIcon
                name="pencil"
                x-small
              />
            </VBtn>
            <VPin
              type="CollectionObject"
              :object-id="collectionObject.id"
            />
            <VBtn
              circle
              color="destroy"
              @click="removeCO(collectionObject.id)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </div>
        </td>
      </tr>

      <template
        v-for="(item, index) in collectionObjects"
        :key="item.id"
      >
        <tr
          class="list-complete-item"
          :class="{ highlight: isSelected(item) }"
          v-if="collectionObject.id != item.id"
        >
          <td>
            <input
              :data-index="index"
              class="total-size co-total-count"
              type="number"
              @change="updateCO(item)"
              v-model="item.total"
            />
          </td>
          <td />
          <td>
            <FormBiocuration
              disabled
              :modelValue="biocurations.filter((b) => b.objectId === item.id)"
              :biocurations-groups="biocurationStore.biocurationGroups"
            />
          </td>
          <td>
            <div class="horizontal-right-content gap-small">
              <AccessionMetadata :collection-object="item" />
              <RadialAnnotator :global-id="item.global_id" />
              <VBtn
                circle
                color="create"
                @click="setCO(item)"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <VPin
                type="CollectionObject"
                :object-id="item.id"
              />
              <VBtn
                circle
                color="destroy"
                @click="removeCO(item.id)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </template>
    </tbody>
  </table>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { computed, ref, watch, onBeforeMount } from 'vue'
import { useStore } from 'vuex'
import { COLLECTION_OBJECT } from '@/constants'
import { BiocurationClassification } from '@/routes/endpoints'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import VLock from '@/components/ui/VLock/index.vue'
import AccessionMetadata from './accession'
import FormBiocuration from '@/components/Form/FormBiocuration.vue'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { randomUUID } from '@/helpers'

const store = useStore()
const biocurationStore = useBiocurationStore()

const biocurations = ref([])

const locked = computed({
  get: () => store.getters[GetterNames.GetLocked],
  set: (value) => store.commit([MutationNames.SetLocked, value])
})

const collectionObjects = computed(
  () => store.getters[GetterNames.GetCollectionObjects]
)

const collectionObject = computed({
  get() {
    return store.getters[GetterNames.GetCollectionObject]
  },
  set(value) {
    store.commit(MutationNames.SetCollectionObject, value)
  }
})

const coTotal = computed(() => collectionObject.value.total)

watch(coTotal, (newVal) => {
  if (newVal < 1) {
    collectionObject.value.total = 1
  }
})

function setCO(co) {
  store.dispatch(ActionNames.LoadDigitalization, co.id)
}

function removeCO(id) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    store.dispatch(ActionNames.RemoveCollectionObject, id)
  }
}

function isSelected(item) {
  return collectionObject.value.id === item.id
}

function updateCO(co) {
  store.dispatch(ActionNames.SaveCollectionObject, co)
}

watch(
  collectionObjects,
  (newVal) => {
    const coIds = newVal
      .map((item) => item.id)
      .filter((id) => collectionObject.value.id !== id)

    if (coIds.length) {
      BiocurationClassification.where({
        biocuration_classification_object_id: newVal.map((item) => item.id),
        biocuration_classification_object_type: COLLECTION_OBJECT
      }).then(({ body }) => {
        biocurations.value = body.map((item) => ({
          id: item.id,
          uuid: randomUUID(),
          objectId: item.biocuration_classification_object_id,
          biocurationClassId: item.biocuration_class_id
        }))
      })
    } else {
      biocurations.value = []
    }
  },
  { deep: true }
)

onBeforeMount(() => {
  biocurationStore.loadBiocurationGroups()
})
</script>

<style scoped>
.highlight {
  outline: 2px solid var(--color-primary);
}
.vue-table {
  min-width: 100%;
}
.lock-biocuration {
  width: 30px;
}
.total-size {
  width: 100px;
}
</style>
