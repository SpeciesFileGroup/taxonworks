<template>
  <div>
    <ProtocolList
      class="margin-medium-bottom"
      :list="protocols"
      @select="addItem"
    />

    <table class="full_width margin-medium-bottom">
      <thead>
        <tr>
          <th class="half_width">
            Change
            <VBtn
              circle
              color="primary"
              :disabled="selected.length < 1"
              @click="() => selected.splice(0, 1)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </th>
          <th class="half_width">
            To
            <VBtn
              circle
              color="primary"
              :disabled="!isFilled"
              @click="() => selected.splice(1, 1)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </th>
          <th class="w-2">
            <VBtn
              color="primary"
              :disabled="!isFilled"
              @click="() => selected.reverse()"
            >
              Flip
            </VBtn>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td v-html="selected[0]?.object_tag"></td>
          <td v-html="selected[1]?.object_tag"></td>
          <td />
        </tr>
      </tbody>
    </table>

    <VBtn
      color="update"
      :disabled="!isFilled"
      @click="() => emit('select', selected)"
    >
      Replace
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import ProtocolList from './ProtocolList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select'])

const selected = ref([])
const isFilled = computed(() => selected.value.length === 2)
const protocols = computed(() =>
  props.list.filter((item) => !selected.value.some((c) => c.id == item.id))
)

function addItem(item) {
  if (selected.value.length < 2) {
    selected.value.push(item)
  }
}
</script>
