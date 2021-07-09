<template>
  <div
    @mouseleave="$emit('update:modelValue', false)"
    class="context-menu">
    <template v-if="metadata">
      <template v-if="defaultPinned">
        <div class="section-title">
          <h3>Add default pinned to</h3>
        </div>
        <ul>
          <template
            v-for="(item, key) in metadata.endpoints"
            :key="key">
            <li
              v-if="getDefault(key)"
              class="cursor-pointer"
              @click="createNew(key)">
              <span class="capitalize">{{ key.replace("_", " ") }}</span>
            </li>
          </template>
        </ul>
      </template>
      <h3 v-else>Set default elements on pinboard</h3>
    </template>
  </div>
</template>

<script>

import CRUD from '../request/crud.js'

export default {
  mixins: [CRUD],

  props: {
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
  },

  emits: ['update:modelValue'],

  computed: {
    defaultPinned () {
      if (this.metadata) {
        const types = Object.keys(this.metadata.endpoints)
        return types.find(item => document.querySelector(`[data-pinboard-section="${this.pinboardTypes[item].type}"] [data-insert="true"]`))
      }
      return undefined
    }
  },
  data () {
    return {
      pinboardTypes: {
        tags: {
          type: 'Keywords',
          idName: 'keyword_id'
        },
        citations: {
          type: 'Sources',
          idName: 'source_id'
        }
      }
    }
  },
  methods: {
    getDefault (type) {
      if(this.pinboardTypes[type]) {
        const defaultElement = document.querySelector(`[data-pinboard-section="${this.pinboardTypes[type].type}"] [data-insert="true"]`)
        return defaultElement ? defaultElement.getAttribute('data-pinboard-object-id') : undefined
      }
      return undefined
    },

    createNew (type) {
      const newObject = {
        annotated_global_entity: decodeURIComponent(this.globalId),
        [this.pinboardTypes[type].idName]: this.getDefault(type)
      }
      this.create(`/${type}`, { [this.singularize(type)]: newObject }).then(response => {
        TW.workbench.alert.create(`${this.singularize(type)} was successfully created.`, 'notice')
      }, (response) => {
        TW.workbench.alert.create(JSON.stringify(response.body), 'error')
      })
    },

    singularize (text) {
      return text.charAt(text.length-1) === 's' ? text.slice(0, text.length-1) : text
    }
  }
}
</script>
<style lang="scss" scoped>
  .section-title {
    background-color: #5D9ECE;
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
    transform: translateX(calc(-50%+24px));
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
      border-bottom: 1px solid #E5E5E5;
      padding-top: 8px;
      white-space: nowrap;
      padding-bottom: 8px;
    }
  }
</style>
