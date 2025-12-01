<template>
  <a :href="makeBrowseLink(notification)">
    <div class="notification-bell-list-item">
      <div>
        <div
          :class="[
            'notification-list-item-type',
            getNewsStyle(notification.type)
          ]"
        >
          <component
            :is="ICON[type]"
            class="w-4 h-4"
          />
        </div>
      </div>
      <div class="flex flex-col gap-xsmall">
        <div
          class="notification-bell-list-item-title"
          v-text="notification.title"
        />
        <div
          class="notification-bell-list-item-body ellipsis"
          v-html="notification.body_html"
        />
        <div class="notification-bell-list-item-time">
          {{ timeAgo(notification.created_at) }}
        </div>
      </div>
    </div>
  </a>
</template>

<script setup>
import { computed } from 'vue'
import { timeAgo } from '@/helpers'
import IconManual from '@/components/Icon/IconManual.vue'
import IconMegaphone from '@/components/Icon/IconMegaphone.vue'
import IconPost from '@/components/Icon/IconPost.vue'
import getNewsStyle from '../utils/getNewsStyle'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  notification: {
    type: Object,
    required: true
  }
})

const ICON = {
  BlogPost: IconPost,
  Notice: IconMegaphone,
  Instruction: IconManual
}

const type = computed(() => props.notification.type.split('::').at(-1))

function makeBrowseLink({ id }) {
  return `${RouteNames.BrowseNews}?news_id=${id}`
}
</script>

<style scoped>
.notification-bell-list-item {
  display: flex;
  flex-direction: row;
  align-items: start;
  box-sizing: border-box;
  width: 400px;
  max-width: 400px;
  padding: 1rem 1.5rem;
  gap: 1rem;
  cursor: pointer;
  color: var(--text-color);
}

.notification-bell-list-item:hover {
  background-color: var(--bg-hover);
}

.notification-list-item-type {
  box-sizing: border-box;
  border-radius: 100%;
  padding: 0.5rem;
  width: 32px;
  height: 32px;
  max-height: 32px;
  max-width: 32px;
  color: white;
}

.notification-bell-list-item-title {
  font-weight: bold;
  font-size: 14px;
}

.notification-bell-list-item:last-child {
  border-bottom: none;
}

.notification-list-item-project-blogpost,
.notification-list-item-admin-blogpost {
  background-color: var(--badge-blue-bg);
  color: var(--badge-blue-color);
}

.notification-list-item-admin-warning {
  background-color: var(--news-warning-color);
}

.notification-list-item-project-notice,
.notification-list-item-admin-notice {
  background-color: var(--badge-yellow-bg);
  color: var(--badge-yellow-color);
}

.notification-list-item-project-instruction {
  background-color: var(--badge-purple-bg);
  color: var(--badge-purple-color);
}

.notification-bell-list-item-body {
  max-width: 300px;
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
  opacity: 0.75;
}

.notification-bell-list-item-time {
  opacity: 0.75;
  font-size: 12px;
}

.notification-bell-list-item-body * {
  display: inline;
  white-space: nowrap !important;
}
</style>
