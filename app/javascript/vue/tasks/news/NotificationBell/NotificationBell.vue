<template>
  <div
    class="notification-bell"
    ref="notificationBell"
  >
    <VBtn
      color="white"
      class="cursor-pointer"
      title="Notifications"
      variant="ghost"
      large
      circle
      @click="() => (isNotificationListVisible = !isNotificationListVisible)"
    >
      <IconBell
        width="18px"
        height="18px"
      />

      <div
        v-if="totalNewNotifications.length"
        class="notification-total"
        v-text="totalNewNotifications.length"
      />
    </VBtn>
    <NotificationList
      v-if="isNotificationListVisible"
      :loading="isLoading"
      :list="notifications"
      :discovered="discoveredNews"
    />
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref, useTemplateRef, watch } from 'vue'
import { News } from '@/routes/endpoints'
import { useClickOutside } from '@/composables'
import { getCurrentProjectId, getCurrentUserId } from '@/helpers'
import NotificationList from './components/NotificationList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconBell from '@/components/Icon/IconBell.vue'

defineOptions({
  name: 'NotificationBell'
})

const projectId = getCurrentProjectId()
const userId = getCurrentUserId()

const storageKey = `discoveredNews-u${userId}-p${projectId}`

const notificationRef = useTemplateRef('notificationBell')
const notifications = ref([])
const discoveredNews = ref(JSON.parse(localStorage.getItem(storageKey) || '[]'))
const isLoading = ref(false)
const isNotificationListVisible = ref(false)

useClickOutside(
  notificationRef,
  () => (isNotificationListVisible.value = false)
)

const totalNewNotifications = computed(() =>
  notifications.value.filter(({ id }) => !discoveredNews.value.includes(id))
)

watch(isNotificationListVisible, (newVal) => {
  const newsId = notifications.value.map((item) => item.id)

  if (!newVal) {
    discoveredNews.value = newsId
    localStorage.setItem(storageKey, JSON.stringify(newsId))
  }
})

onBeforeMount(() => {
  isLoading.value = true
  News.where({ per: 10 })
    .then(({ body }) => {
      notifications.value = body
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
  display: flex;
  justify-content: center;
  align-items: center;
  bottom: 18px;
  right: 4px;
  width: 12px;
  height: 12px;
  font-size: 8px;
  border-radius: 100%;
  text-align: center;
  background-color: var(--color-error);
}
</style>
