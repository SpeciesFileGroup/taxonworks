<template>
  <div class="flex-wrap-row">
    <ul class="flex-wrap-column no_bullets">
      <template v-for="item in objectLists">
        <li
          class="status-item"
          :key="item.id"
          v-if="!filter || !filterAlreadyPicked(listCreated, item.type)"
        >
          <label>
            <input
              type="radio"
              name="status-item"
              :value="item.base_class"
              @click="emit('addEntry', item)"
            >
            <span>{{ item[display] }}</span>
          </label>
        </li>
      </template>
    </ul>
  </div>
</template>
<script setup>
defineProps({
  objectLists: {
    type: Array,
    default: () => []
  },

  listCreated: {
    type: Array,
    required: true
  },

  display: {
    type: String,
    required: true
  },

  filter: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits('addEntry')

function filterAlreadyPicked (list, type) {
  return list.find(item => item.type === type)
}
</script>
