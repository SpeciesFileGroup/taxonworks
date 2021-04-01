<template>
  <div v-if="!deleted">
    <div class="radial-annotator">
      <modal
        v-if="display"
        :container-style="{ backgroundColor: 'transparent', boxShadow: 'none' }"
        @close="closeModal()">
        <h3
          slot="header"
          class="flex-separate">
          <span v-html="title" />
          <span
            v-if="metadata"
            class="separate-right"> {{ metadata.type }}</span>
        </h3>
        <div
          slot="body"
          class="flex-separate">
          <spinner v-if="loading" />
          <div class="radial-annotator-menu">
            <div>
              <radial-menu
                v-if="menuCreated"
                :options="menuOptions"
                @onClick="selectedRadialOption"/>
            </div>
          </div>
          <div
            class="radial-annotator-template panel"
            :style="{ 'max-height': windowHeight(), 'min-height': windowHeight() }"
            v-if="currentView">
            <h2 class="capitalize view-title">
              {{ currentView.replace("_"," ") }}
            </h2>
            <component
              class="radial-annotator-container"
              :is="(currentView ? currentView + 'Component' : undefined)"
              :type="currentView"
              :metadata="metadata"
              :global-id="globalId"
              @onSelectedGlobalId="loadMetadata"
              @updateCount="setTotal"/>
          </div>
          <destroy-confirmation
            v-if="showDestroyModal"
            @close="showDestroyModal = false"
            @confirm="destroyObject"/>
        </div>
      </modal>
      <span
        v-if="showBottom"
        :title="buttonTitle"
        type="button"
        class="circle-button"
        :class="[buttonClass]"
        @click="displayRadialObject()">Radial annotator
      </span>
    </div>
  </div>
</template>
<script>

import RadialMenu from 'components/radials/RadialMenu.vue'
import Modal from 'components/modal.vue'
import Spinner from 'components/spinner.vue'

import CRUD from './request/crud'
import Icons from './images/icons.js'

import RecentComponent from './components/recent.vue'
import DestroyConfirmation from './components/DestroyConfirmation'
import all_tasksComponent from './components/allTasks.vue'

const defaultOptions = {
  New: 'New',
  Edit: 'Edit',
  Destroy: 'Destroy',
  Recent: 'Recent',
  Show: 'Show'
}

export default {
  mixins: [CRUD],
  name: 'RadialNavigation',
  components: {
    all_tasksComponent,
    RecentComponent,
    RadialMenu,
    Modal,
    Spinner,
    DestroyConfirmation
  },
  props: {
    reload: {
      type: Boolean,
      default: false
    },
    globalId: {
      type: String,
      required: true
    },
    showBottom: {
      type: Boolean,
      default: true
    },
    buttonClass: {
      type: String,
      default: 'btn-radial-object'
    },
    buttonTitle: {
      type: String,
      default: 'Navigate radial'
    },
    maxTaskInPie: {
      type: Number,
      default: 4
    },
    components: {
      type: Object,
      default: () => {
        return {}
      }
    },
    filterOptions: {
      type: [String, Array],
      default: () => { return [] }
    }
  },

  computed: {
    menuOptions () {
      const tasks = this.metadata.tasks || {}
      const slices = [].concat(this.defaultSlices, Object.entries(tasks).slice(0, this.maxTaskInPie).map(([task, { name, path }]) => ({
        name: task,
        label: name,
        link: path,
        icon: Icons[task]
          ? {
              url: Icons[task],
              width: '20',
              height: '20'
            }
          : undefined
      })))

      if (Object.keys(tasks).length > this.maxTaskInPie) {
        slices.push({
          label: 'All tasks',
          name: 'alltasks',
          icon: {
            url: Icons.AllTasks,
            width: '20',
            height: '20'
          }
        })
      }

      if (this.metadata?.recent_url) {
        slices.push(this.addSlice(defaultOptions.Recent,
          this.recentTotal
            ? {
                slices: [{
                  size: 26,
                  label: this.recentTotal.toString(),
                  svgAttributes: {
                    fill: '#006ebf',
                    color: '#FFFFFF'
                  }
                }]
              }
            : {}
        ))
      }
      return {
        width: 400,
        height: 400,
        sliceSize: 130,
        centerSize: 34,
        innerPosition: 1.6,
        margin: 2,
        middleButton: this.middleButton,
        css: {
          class: 'svg-radial-annotator'
        },
        svgAttributes: {
          fontSize: 11,
          fill: '#FFFFFF',
          textAnchor: 'middle'
        },
        slices: slices
      }
    },
    defaultSlices () {
      const filterOptions = this.filterOptions

      if (!this.metadata.destroy) {
        filterOptions.push(this.addSlice(defaultOptions.Destroy))
      }

      return this.defaultSlicesTypes.filter(type => !filterOptions.includes(type)).map(type => this.addSlice(type, { link: this.defaultLinks()[type] }))
    },
    menuCreated () {
      return this.metadata
    },
    isPinned () {
      return this.metadata['pinboard_item']
    },
    middleButton () {
      return {
        name: 'circleButton',
        radius: 30,
        icon: {
          url: Icons.Pin,
          width: '20',
          height: '20'
        },
        svgAttributes: {
          fill: this.isPinned ? '#F44336' : '#9ccc65'
        }
      }
    }
  },

  data () {
    return {
      loading: false,
      currentView: undefined,
      display: false,
      globalIdSaved: undefined,
      metadata: undefined,
      title: 'Radial object',
      deleted: false,
      showDestroyModal: false,
      recentTotal: 0,
      customOptions: ['alltasks', 'circleButton'],
      defaultSlicesTypes: [
        defaultOptions.New,
        defaultOptions.Destroy,
        defaultOptions.Edit,
        defaultOptions.Show
      ]
    }
  },

  methods: {
    addSlice (type, attr) {
      return {
        label: type,
        name: type,
        radius: 30,
        icon: {
          url: Icons[type],
          width: '20',
          height: '20'
        },
        ...attr
      }
    },
    selectedRadialOption ({ name }) {
      if (Object.keys(defaultOptions).includes(name) || this.customOptions.includes(name)) {
        this.currentView = undefined
        switch (name) {
          case 'circleButton':
            this.isPinned ? this.destroyPin() : this.createPin()
            break
          case defaultOptions.Recent:
            this.currentView = 'Recent'
            break
          case defaultOptions.Edit:
            window.open(this.metadata['edit'] ? this.metadata.edit : `${this.metadata.resource_path}/edit`)
            break
          case defaultOptions.New:
            window.open(this.metadata['new'] ? this.metadata.new : `${this.metadata.resource_path.substring(0, this.metadata.resource_path.lastIndexOf('/'))}/new`)
            break
          case defaultOptions.Show:
            window.open(this.metadata.resource_path)
            break
          case defaultOptions.Destroy:
            this.showDestroyModal = true
            break
          case 'alltasks':
            this.currentView = 'all_tasks'
            break
        }
      }
    },
    defaultLinks () {
      return {
        [defaultOptions.Edit]: this.metadata?.edit || `${this.metadata.resource_path}/edit`,
        [defaultOptions.New]: this.metadata?.new || `${this.metadata.resource_path.substring(0, this.metadata.resource_path.lastIndexOf('/'))}/new`,
        [defaultOptions.Show]: this.metadata.resource_path
      }
    },
    closeModal () {
      this.display = false
      this.eventClose()
      this.$emit('close')
    },
    displayRadialObject () {
      this.display = true
      this.currentView = undefined
      this.loadMetadata(this.globalId)
    },
    loadMetadata (globalId) {
      if (globalId == this.globalIdSaved && this.menuCreated && !this.reload) return
      this.globalIdSaved = globalId
      this.loading = true

      this.getList(`/metadata/object_radial?global_id=${encodeURIComponent(globalId)}`).then(response => {
        this.metadata = response.body
        this.title = this.metadata.object_label

        this.loading = false
      })
    },
    setTotal (total) {
      this.recentTotal = total
    },
    eventClose () {
      const event = new CustomEvent('radialObject:close', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },
    eventDestroy () {
      const event = new CustomEvent('radialObject:destroy', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },
    windowHeight () {
      return ((window.innerHeight - 100) > 650 ? 650 : window.innerHeight - 100) + 'px !important'
    },
    createPin () {
      const pinItem = {
        pinboard_item: {
          pinned_object_id: this.metadata.id,
          pinned_object_type: this.metadata.type,
          is_inserted: true
        }
      }
      this.create('/pinboard_items', pinItem).then(response => {
        this.$set(this.metadata, 'pinboard_item', { id: response.body.id })
        TW.workbench.pinboard.addToPinboard(response.body)
        TW.workbench.alert.create('Pinboard item was successfully created.', 'notice')
      })
    },
    destroyPin: function () {
      this.destroy(`/pinboard_items/${this.metadata.pinboard_item.id}`, { _destroy: true }).then(response => {
        TW.workbench.alert.create('Pinboard item was successfully destroyed.', 'notice')
        TW.workbench.pinboard.removeItem(this.metadata.pinboard_item.id)
        this.$delete(this.metadata, 'pinboard_item')
      })
    },
    destroyObject () {
      this.showDestroyModal = false
      this.destroy(`${this.metadata.resource_path}.json`).then((response) => {
        TW.workbench.alert.create(`${this.metadata.type} was successfully destroyed.`, 'notice')
        if (this.globalId === this.metadata.globalId) {
          this.eventDestroy()
          this.deleted = true
        }
        if (window.location.pathname == this.metadata.resource_path) {
          window.open(`/${window.location.pathname.split('/')[1]}`, '_self')
        } else {
          window.open(this.metadata.resource_path.substring(0, this.metadata.resource_path.lastIndexOf('/')), '_self')
        }
      })
    }
  }
}
</script>
