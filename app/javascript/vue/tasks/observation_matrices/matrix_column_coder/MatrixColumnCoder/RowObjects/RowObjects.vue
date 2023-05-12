<template>
  <div>
    <v-btn
      class="middle"
      medium
      color="primary"
      @click="setModalView(true)"
    >
      <VIcon
        name="compass"
        x-small
      />
      <span class="margin-small-left">Row objects</span>
    </v-btn>
    <v-modal
      v-if="isVisible"
      @close="setModalView(false)"
      :container-style="{ width: '800px' }"
    >
      <template #header>
        <h3>Row objects</h3>
      </template>
      <template #body>
        <ul class="matrix-row-coder__descriptor-menu flex-wrap-column no_bullets">
          <li
            v-for="rowObject in rowObjects"
            :key="rowObject.id"
            class="margin-small-bottom"
          >
            <div>
              <a
                class="matrix-row-coder__descriptor-item"
                :data-icon="observationsCount({ rowObjectId: rowObject.id, rowObjectType: rowObject.type }) ? 'ok' : false"
                @click="scrollToDescriptor(rowObject.id)"
                v-html="rowObject.title"
              />
            </div>
          </li>
        </ul>
      </template>
    </v-modal>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { ref, computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const store = useStore()
const rowObjects = computed(() => store.getters[GetterNames.GetRowObjects])
const isVisible = ref(false)

const scrollToDescriptor = rowObjectId => {
  const top = document.querySelector(`[data-row-object-id="${rowObjectId}"]`).getBoundingClientRect().top + window.pageYOffset - 80

  window.scrollTo({ top })
  setModalView(false)
}

const observationsCount = ({ rowObjectId, rowObjectType }) => {
  return store.getters[GetterNames.GetObservationsFor]({ rowObjectId, rowObjectType })
    .find(item => Boolean(item.id))
}

const setModalView = value => {
  isVisible.value = value
}
</script>
