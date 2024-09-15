<template>
  <VBtn
    color="primary"
    :disabled="disabled"
    @click="() => (isModalVisible = true)"
  >
    Place selected
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
    :container-style="{
      width: '800px'
    }"
  >
    <template #header>
      <h3>Place selected</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content gap-medium align-start">
        <div>
          <label>
            Defines the incremental position that will be used to fill the
            container
          </label>
          <div class="padding-medium-bottom padding-medium-top">
            <ul class="no_bullets">
              <li
                v-for="value in DIRECTIONS"
                :key="value"
              >
                <label>
                  <input
                    type="radio"
                    v-model="direction"
                    :value="value"
                    @click="() => (counter = 1)"
                  />
                  {{ value.split('').join(' → ') }}
                </label>
              </li>
            </ul>
          </div>
          <VBtn
            color="primary"
            medium
            @click="
              () => {
                store.fillContainer(list, {
                  override,
                  direction: direction.split('')
                })
                isModalVisible = false
              }
            "
          >
            Place
          </VBtn>
        </div>
        <VueEncase
          class="container-viewer"
          v-bind="encaseOpts"
        />
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useContainerStore } from '../../store'
import { VueEncase } from '@sfgrp/encase'
import { DEFAULT_COLOR, DEFAULT_OPTS } from '../../constants'
import { useInterval } from '@/composables'
import { convertPositionTo3DGraph } from '../../utils'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const DIRECTIONS = ['xyz', 'xzy', 'yxz', 'yzx', 'zxy', 'zyx']

defineProps({
  disabled: {
    type: Boolean,
    default: false
  },

  list: {
    type: Array,
    default: () => []
  }
})

const store = useContainerStore()
const direction = ref('xzy')
const override = ref(false)
const isModalVisible = ref(false)
const counter = ref(0)

const totalCells = computed(() =>
  Object.values(store.container.size).reduce(
    (acc, curr) => acc * (curr || 1),
    1
  )
)

const { stop, resume } = useInterval(() => {
  if (counter.value < totalCells.value) {
    counter.value++
  } else {
    counter.value = 1
  }
}, 250)
stop()

watch(isModalVisible, (newVal) => {
  if (newVal) {
    counter.value = 1
    resume()
  } else {
    stop()
  }
})

function fillContainer({ direction }) {
  const items = []
  let index = 1

  for (let i = 0; i < store.container.size[direction[2]]; i++) {
    for (let j = 0; j < store.container.size[direction[1]]; j++) {
      for (let k = 0; k < store.container.size[direction[0]]; k++) {
        const position = {
          [direction[2]]: i,
          [direction[1]]: j,
          [direction[0]]: k
        }

        items.push({
          position: convertPositionTo3DGraph(position, store.container.size),
          label: String(index),
          style: {
            color: DEFAULT_COLOR
          }
        })

        if (items.length == counter.value) {
          return items
        }

        index++
      }
    }
  }

  return items
}

const encaseOpts = computed(() => {
  return {
    ...DEFAULT_OPTS,
    cameraPosition: {
      x: 50,
      y: 50,
      z: 50
    },
    container: {
      sizeX: store.container.size.x,
      sizeY: store.container.size.y,
      sizeZ: store.container.size.z,
      containerItems: fillContainer({ direction: direction.value })
    }
  }
})
</script>

<style lang="scss" scoped>
.container-viewer {
  width: 500px;
  height: 400px;
}
</style>
