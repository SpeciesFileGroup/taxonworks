<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th class="w-2">
          <input
            type="checkbox"
            v-model="selectOtus"
          />
        </th>
        <th>Name</th>
        <th>Taxon name</th>
        <th>Exist?</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(item, index) in list"
        :key="item.id"
        :class="{ 'duplicated-otu': item.exist }"
      >
        <td>
          <input
            type="checkbox"
            :value="item.uuid"
            v-model="selected"
          />
        </td>
        <td>{{ item.name }}</td>
        <td v-html="item.taxonName?.cached" />
        <td>{{ item.exist ? 'Yes' : 'No' }}</td>
        <td>
          <div class="horizontal-right-content gap-small">
            <VBtn
              color="create"
              medium
              @click="emit('create', { item, index })"
            >
              Create
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  },

  taxonName: {
    type: Object,
    default: () => ({})
  }
})

const selected = defineModel({
  type: Array,
  required: true
})

const selectOtus = computed({
  get: () =>
    props.list.length === selected.value.length && props.list.length > 0,
  set: (value) =>
    emit('update:modelValue', value ? props.list.map((item) => item.uuid) : [])
})

const emit = defineEmits(['remove', 'create'])
</script>

<style scoped>
.duplicated-otu {
  background: #fcdfb4 !important;
}
</style>
