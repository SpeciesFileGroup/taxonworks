<template>
  <div
    @mouseleave="emit('update:modelValue', false)"
    class="context-menu"
  >
    <template v-if="metadata">
      <template v-if="defaultPinned">
        <div class="section-title">
          <h3>Add default pinned to</h3>
        </div>
        <ul>
          <template
            v-for="(item, key) in metadata.endpoints"
            :key="key"
          >
            <li
              v-if="getDefault(key)"
              class="cursor-pointer"
              @click="createNew(key)"
            >
              <span class="capitalize">{{ key.replace('_', ' ') }}</span>
            </li>
          </template>
        </ul>
      </template>
      <h3 v-else>Set default elements on pinboard</h3>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import makeRequest from '@/helpers/ajaxCall'

const PINBOARD_TYPES = {
  tags: {
    type: 'Keywords',
    idName: 'keyword_id'
  },
  citations: {
    type: 'Sources',
    idName: 'source_id'
  }
}

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },

  metadata: {
    type: Object,
    default: undefined
  },

  globalId: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const defaultPinned = computed(() => {
  if (props.metadata) {
    const types = Object.keys(props.metadata.endpoints)
    return types.find((item) =>
      document.querySelector(
        `[data-pinboard-section="${props.pinboardTypes[item]?.type}"] [data-insert="true"]`
      )
    )
  }
  return undefined
})

function getDefault(type) {
  if (PINBOARD_TYPES[type]) {
    const defaultElement = document.querySelector(
      `[data-pinboard-section="${PINBOARD_TYPES[type].type}"] [data-insert="true"]`
    )
    return defaultElement?.getAttribute('data-pinboard-object-id')
  }
  return undefined
}

function createNew(type) {
  const newObject = {
    annotated_global_entity: decodeURIComponent(props.globalId),
    [PINBOARD_TYPES[type].idName]: getDefault(type)
  }

  makeRequest('post', `/${type}`, { [singularize(type)]: newObject })
    .then((_) => {
      TW.workbench.alert.create(
        `${singularize(type)} was successfully created.`,
        'notice'
      )
    })
    .catch(() => {})
}

function singularize(text) {
  return text.charAt(text.length - 1) === 's'
    ? text.slice(0, text.length - 1)
    : text
}
</script>
<style lang="scss" scoped>
.section-title {
  background-color: #5d9ece;
  color: white;
  width: 100%;

  h3 {
    margin: 14px;
    margin-top: 0px;
    margin-bottom: 0px;
    width: 100%;
    padding-top: 8px;
    padding-bottom: 8px;
  }
}

.context-menu {
  box-sizing: border-box;
  transform: translateX(calc(-50% + 24px));
  z-index: 999;
  position: absolute;
  background-color: white;
  box-shadow: 0px 2px 2px 0px rgba(0, 0, 0, 0.2);
  min-width: 200px;
  display: block;
  ul {
    margin: 8px;
    margin-top: 0px;
    list-style: none;
    padding: 0px;
  }

  li:last-child {
    border-bottom: none;
    padding-bottom: 0px;
  }

  li {
    width: 100%;
    border-bottom: 1px solid #e5e5e5;
    padding-top: 8px;
    white-space: nowrap;
    padding-bottom: 8px;
  }
}
</style>
