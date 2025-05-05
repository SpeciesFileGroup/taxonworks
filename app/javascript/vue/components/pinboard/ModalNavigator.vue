<template>
  <VModal>
    <template #header>
      <h3>Pinboard navigator - Browse tasks</h3>
    </template>
    <template #body>
      <ul
        v-if="Object.keys(defaultItems).length"
        class="no_bullets"
      >
        <template
          v-for="(item, key) in sections"
          :key="key"
        >
          <li
            class="margin-small-bottom"
            v-if="defaultItems[key]"
          >
            <transition
              v-if="selected && selected.klass == key"
              name="bounce"
              @after-enter="redirect"
              appear
            >
              <div class="horizontal-left-content cursor-pointer">
                <div
                  class="rounded-circle button-default horizontal-center-content circle-s middle margin-small-right"
                >
                  <span class="capitalize"
                    ><b>{{ item.shortcut }}</b></span
                  >
                </div>
                <span v-html="shorten(defaultItems[key].label, 38)" />
              </div>
            </transition>
            <div
              v-else
              class="cursor-pointer dislay-inline-flex align-center"
              @click="selectItem(key, defaultItems[key])"
            >
              <div
                class="rounded-circle button-default horizontal-center-content circle-s middle margin-small-right"
              >
                <span class="capitalize"
                  ><b>{{ item.shortcut }}</b></span
                >
              </div>
              <span v-html="shorten(defaultItems[key].label, 38)" />
            </div>
          </li>
        </template>
      </ul>
      <h4 v-else>Nothing is on your pinboard yet</h4>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import Shortcuts from './const/shortcuts.js'
import { useHotkey } from '@/composables'
import { shorten } from '@/helpers/strings.js'
import { computed, ref, onBeforeMount } from 'vue'

defineOptions({
  name: 'PinboardNavigator'
})

const defaultItems = ref({})
const selected = ref(null)
const sections = ref(Shortcuts)

const hotkeys = computed(() => {
  const keys = Object.entries(sections.value).map(([key, { shortcut }]) => ({
    keys: [shortcut],
    handler() {
      selectItem(key, defaultItems.value[key])
    }
  }))

  return keys
})

useHotkey(hotkeys.value)

function redirect() {
  const selectedKlass = selected.value.klass
  const { path, param } = sections.value[selectedKlass]

  window.open(`${path}?${param}=${selected.value.object.id}`, '_self')
}

function selectItem(key, item) {
  selected.value = { klass: key, object: item }
}

onBeforeMount(() => {
  defaultItems.value = {}

  document.querySelectorAll('[data-pinboard-section]').forEach((node) => {
    const element = node.querySelector('[data-insert="true"]')

    if (element) {
      defaultItems.value[node.getAttribute('data-pinboard-section')] = {
        id: element.getAttribute('data-pinboard-object-id'),
        label: element.querySelector('a').textContent
      }
    }
  })

  selected.value = undefined
})
</script>
<style scoped>
.bounce-enter-active {
  animation: bounce-in 1s;
}
.bounce-leave-active {
  animation: bounce-in 1s reverse;
}
@keyframes bounce-in {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.5) translateX(25%);
  }
  100% {
    transform: scale(1);
  }
}
</style>
