<template>
  <div
    class="notification-bell"
    ref="notificationBell"
  >
    <div
      class="cursor-pointer h-5"
      @click="() => (isNotificationListVisible = !isNotificationListVisible)"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="w-5 h-5"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0"
        />
      </svg>

      <div
        v-if="notifications.length"
        class="notification-total"
        v-text="notifications.length"
      />
    </div>
    <NotificationList
      v-if="isNotificationListVisible"
      :loading="isLoading"
      :list="notifications"
    />
  </div>
</template>

<script setup>
import { onBeforeMount, ref, useTemplateRef } from 'vue'
import { News } from '@/routes/endpoints'
import { useClickOutside } from '@/composables'
import NotificationList from './components/NotificationList.vue'

const notificationRef = useTemplateRef('notificationBell')
const notifications = ref([])
const isLoading = ref(false)

const isNotificationListVisible = ref(false)

useClickOutside(
  notificationRef,
  () => (isNotificationListVisible.value = false)
)

onBeforeMount(() => {
  isLoading.value = true
  News.where({})
    .then(({ body }) => {
      notifications.value = body.reverse()
    })
    .finally(() => {
      isLoading.value = false
    })
})
</script>

<style scoped>
.notification-bell {
  display: block;
  position: relative;
}

.notification-total {
  position: absolute;
  bottom: 0px;
  right: -2px;
  width: 12px;
  height: 12px;
  font-size: 8px;
  border-radius: 100%;
  text-align: center;
  vertical-align: center;
  background-color: var(--color-error);
}
</style>
