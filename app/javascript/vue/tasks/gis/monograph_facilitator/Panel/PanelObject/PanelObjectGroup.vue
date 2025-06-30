<template>
  <div
    class="group"
    :style="`border-color: ${group.color}`"
  >
    <div class="group-header padding-small">
      <label class="group-label ellipsis">
        <input
          type="checkbox"
          v-model="selectAll"
        />
        <span v-html="group.determination.label" />
      </label>
    </div>
    <ul class="no_bullets group-list">
      <li
        v-for="item in group.list"
        :key="item.id"
        class="ellipsis"
      >
        <label>
          <input
            type="checkbox"
            :value="item.objectId"
            v-model="store.selectedIds"
          />
          <span v-html="item.label" />
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import useStore from '../../store/store.js'

const props = defineProps({
  group: {
    type: Object,
    required: true
  }
})

const store = useStore()

const selectAll = computed({
  get: () =>
    props.group.list.every((item) => store.selectedIds.includes(item.objectId)),
  set: (value) => {
    const groupIds = props.group.list.map((item) => item.objectId)

    if (value) {
      props.group.list.forEach((item) => {
        if (!store.selectedIds.includes(item.objectId)) {
          store.selectedIds.push(item.objectId)
        }
      })
    } else {
      store.selectedIds = store.selectedIds.filter(
        (id) => !groupIds.includes(id)
      )
    }
  }
})
</script>

<style scoped>
.group {
  border-left: 4px solid;

  .group-header {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    background-color: var(--border-color);
  }

  .group-label {
    width: 380px;
    max-width: 380px;
  }

  .group-header {
    width: 380px;
    max-width: 380px;
  }

  .group-list {
    li {
      width: 380px;
      max-width: 380px;
      padding: 0.5rem;
      box-sizing: border-box;
      border-bottom: 1px solid var(--border-color);
    }
  }
}
</style>
