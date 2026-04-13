<template>
  <div class="notification-bell-list-container">
    <VSpinner v-if="loading" />

    <div class="notification-bell-list-container-title">
      <h3>Notifications</h3>
      <a :href="RouteNames.BrowseNews">Show all </a>
    </div>

    <div
      v-if="list.length"
      class="notification-bell-list-items"
    >
      <NotificationListItem
        v-for="item in list"
        :key="item.id"
        :discovered="discovered.some((id) => item.id)"
        :notification="item"
      />
    </div>
    <div
      v-else
      class="flex flex-col full_width middle"
    >
      <h3>There is no news.</h3>
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
import NotificationListItem from './NotificationListItem.vue'
import { RouteNames } from '@/routes/routes'

defineProps({
  list: {
    type: Array,
    required: true
  },

  discovered: {
    type: Array,
    required: true
  },

  loading: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped>
.notification-bell-list-container {
  position: absolute;
  z-index: 1980;
  background-color: var(--bg-foreground);
  right: 0;
  width: 400px;
  max-width: 400px;
  top: 100%;
  color: var(--text-color);
  box-shadow: var(--panel-shadow);
  border-radius: var(--border-radius-small);
}

.notification-bell-list-items {
  max-height: 70vh;
  overflow-y: auto;
}

.notification-bell-list-container-title {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 0 1rem;
  border-bottom: 1px solid var(--border-color);
}
</style>
