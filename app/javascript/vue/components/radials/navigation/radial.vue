<template>
  <div v-if="!deleted">
    <div class="radial-annotator">
      <modal
        v-if="display"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <h3 class="flex-separate">
            <span v-html="title" />
            <span
              v-if="metadata"
              class="separate-right"
              v-text="metadata.type"
            />
          </h3>
        </template>
        <template #body>
          <div class="flex-separate">
            <spinner v-if="loading" />
            <div class="radial-annotator-menu">
              <div>
                <radial-menu
                  v-if="menuCreated"
                  :options="menuOptions"
                  @onClick="selectedRadialOption"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              :style="{
                'max-height': windowHeight(),
                'min-height': windowHeight()
              }"
              v-if="currentView"
            >
              <h2 class="capitalize view-title">
                {{ currentView.replace('_', ' ') }}
              </h2>
              <component
                class="radial-annotator-container"
                :is="currentView ? currentView + 'Component' : undefined"
                :type="currentView"
                :metadata="metadata"
                :global-id="globalId"
                @onSelectedGlobalId="loadMetadata"
                @updateCount="setTotal"
              />
            </div>
            <destroy-confirmation
              v-if="showDestroyModal"
              @close="showDestroyModal = false"
              @confirm="destroyObject"
            />
          </div>
        </template>
      </modal>
      <VBtn
        v-if="showBottom"
        :title="buttonTitle"
        class="circle-button"
        color="radial"
        circle
        :disabled="disabled"
        @click="openRadialMenu()"
      >
        <VIcon
          :title="buttonTitle"
          name="radialNavigator"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>
<script>
import RadialMenu from 'components/radials/RadialMenu.vue'
import Modal from 'components/ui/Modal.vue'
import Spinner from 'components/spinner.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

import CRUD from './request/crud'
import Icons from './images/icons.js'

import RecentComponent from './components/recent.vue'
import DestroyConfirmation from './components/DestroyConfirmation'
import all_tasksComponent from './components/allTasks.vue'

import { PinboardItem } from 'routes/endpoints'

const DEFAULT_OPTIONS = {
  New: 'New',
  Edit: 'Edit',
  Destroy: 'Destroy',
  Recent: 'Recent',
  Show: 'Show',
  Related: 'Related'
}

const CUSTOM_OPTIONS = {
  AllTasks: 'allTasks',
  CircleButton: 'circleButton'
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
    DestroyConfirmation,
    VBtn,
    VIcon
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

    buttonTitle: {
      type: String,
      default: 'Radial navigator'
    },

    maxTaskInPie: {
      type: Number,
      default: 4
    },

    components: {
      type: Object,
      default: () => ({})
    },

    filterOptions: {
      type: [String, Array],
      default: () => []
    },

    disabled: {
      type: Boolean,
      default: false
    }
  },

  emits: ['close'],

  computed: {
    defaultTasks() {
      return {
        graph_object: {
          name: 'Object graph',
          path: `/tasks/graph/object?global_id=${encodeURIComponent(
            this.globalId
          )}`
        }
      }
    },

    menuOptions() {
      const tasks = this.metadata.tasks || {}
      const taskSlices = Object.entries(tasks)
        .slice(0, this.maxTaskInPie)
        .map(([task, { name, path }]) => ({
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
        }))

      if (Object.keys(tasks).length > this.maxTaskInPie) {
        taskSlices.push({
          label: 'All tasks',
          name: CUSTOM_OPTIONS.AllTasks,
          svgAttributes: {
            class: 'slice'
          },
          icon: {
            url: Icons.AllTasks,
            width: '20',
            height: '20'
          }
        })
      }

      if (this.metadata?.recent_url) {
        taskSlices.push(
          this.addSlice(
            DEFAULT_OPTIONS.Recent,
            this.recentTotal
              ? {
                  slices: [
                    {
                      size: 26,
                      label: this.recentTotal.toString(),
                      svgAttributes: {
                        class: 'slice-total'
                      }
                    }
                  ]
                }
              : {}
          )
        )
      }

      const slices = [...taskSlices, ...this.defaultSlices]

      return {
        width: 400,
        height: 400,
        sliceSize: 130,
        centerSize: 34,
        innerPosition: 1.7,
        margin: 0,
        middleButton: this.middleButton,
        svgAttributes: {
          class: 'svg-radial-menu svg-radial-menu-navigator'
        },
        svgSliceAttributes: {
          fontSize: 11,
          class: 'slice'
        },
        slices
      }
    },

    defaultSlices() {
      const filterOptions = this.filterOptions

      if (!this.metadata.destroy) {
        filterOptions.push(this.addSlice(DEFAULT_OPTIONS.Destroy))
      }

      return this.defaultSlicesTypes
        .filter((type) => !filterOptions.includes(type))
        .map((type) => this.addSlice(type, { link: this.defaultLinks()[type] }))
    },

    menuCreated() {
      return this.metadata
    },

    isPinned() {
      return this.metadata?.pinboard_item
    },

    middleButton() {
      return {
        name: CUSTOM_OPTIONS.CircleButton,
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

  data() {
    return {
      loading: false,
      currentView: undefined,
      display: false,
      globalIdSaved: undefined,
      metadata: undefined,
      title: 'Radial navigation',
      deleted: false,
      showDestroyModal: false,
      recentTotal: 0,
      defaultSlicesTypes: [
        DEFAULT_OPTIONS.Related,
        DEFAULT_OPTIONS.New,
        DEFAULT_OPTIONS.Destroy,
        DEFAULT_OPTIONS.Edit,
        DEFAULT_OPTIONS.Show
      ]
    }
  },

  methods: {
    addSlice(type, attr) {
      return {
        label: type,
        name: type,
        radius: 30,
        icon: {
          url: Icons[type],
          width: '20',
          height: '20'
        },
        svgAttributes: {
          class: 'slice'
        },
        ...attr
      }
    },

    selectedRadialOption({ name }) {
      switch (name) {
        case CUSTOM_OPTIONS.CircleButton:
          this.isPinned ? this.destroyPin() : this.createPin()
          break
        case DEFAULT_OPTIONS.Recent:
          this.currentView = 'Recent'
          break
        case DEFAULT_OPTIONS.Destroy:
          this.showDestroyModal = true
          break
        case CUSTOM_OPTIONS.AllTasks:
          this.currentView = 'all_tasks'
          break
      }
    },

    defaultLinks() {
      return {
        [DEFAULT_OPTIONS.Edit]:
          this.metadata?.edit || `${this.metadata.resource_path}/edit`,
        [DEFAULT_OPTIONS.New]:
          this.metadata?.new ||
          `${this.metadata.resource_path.substring(
            0,
            this.metadata.resource_path.lastIndexOf('/')
          )}/new`,
        [DEFAULT_OPTIONS.Show]: this.metadata.resource_path,
        [DEFAULT_OPTIONS.Related]: `/tasks/shared/related_data?object_global_id=${encodeURIComponent(
          this.globalId
        )}`
      }
    },

    closeModal() {
      this.display = false
      this.eventClose()
      this.$emit('close')
    },

    openRadialMenu() {
      this.display = true
      this.currentView = undefined
      this.loadMetadata(this.globalId)
    },

    loadMetadata(globalId) {
      if (globalId == this.globalIdSaved && this.menuCreated && !this.reload)
        return
      this.globalIdSaved = globalId
      this.loading = true

      this.getList(
        `/metadata/object_radial?global_id=${encodeURIComponent(globalId)}`
      ).then(({ body }) => {
        const { tasks, ...rest } = body

        this.metadata = rest
        this.metadata.tasks = {
          ...tasks,
          ...this.defaultTasks
        }
        this.title = this.metadata.object_label
        this.loading = false
      })
    },

    setTotal(total) {
      this.recentTotal = total
    },

    eventClose() {
      const event = new CustomEvent('radialObject:close', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },

    eventDestroy() {
      const event = new CustomEvent('radialObject:destroy', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },

    windowHeight() {
      return (
        (window.innerHeight - 100 > 650 ? 650 : window.innerHeight - 100) +
        'px !important'
      )
    },

    createPin() {
      const pinboard_item = {
        pinned_object_id: this.metadata.id,
        pinned_object_type: this.metadata.type,
        is_inserted: true
      }

      PinboardItem.create({ pinboard_item }).then(({ body }) => {
        this.metadata.pinboard_item = { id: body.id }
        TW.workbench.pinboard.addToPinboard(body)
        TW.workbench.alert.create(
          'Pinboard item was successfully created.',
          'notice'
        )
      })
    },

    destroyPin() {
      PinboardItem.destroy(this.metadata.pinboard_item.id).then((_) => {
        TW.workbench.alert.create(
          'Pinboard item was successfully destroyed.',
          'notice'
        )
        TW.workbench.pinboard.removeItem(this.metadata.pinboard_item.id)
        delete this.metadata.pinboard_item
      })
    },

    destroyObject() {
      this.showDestroyModal = false
      this.destroy(`${this.metadata.resource_path}.json`).then((_) => {
        TW.workbench.alert.create(
          `${this.metadata.type} was successfully destroyed.`,
          'notice'
        )
        if (this.globalId === this.metadata.globalId) {
          this.eventDestroy()
          this.deleted = true
        }

        if (this.metadata.destroyed_redirect) {
          window.open(this.metadata.destroyed_redirect, '_self')
        } else if (window.location.pathname === this.metadata.resource_path) {
          window.open(`/${window.location.pathname.split('/')[1]}`, '_self')
        } else {
          window.open(
            this.metadata.resource_path.substring(
              0,
              this.metadata.resource_path.lastIndexOf('/')
            ),
            '_self'
          )
        }
      })
    }
  }
}
</script>

<style>
.svg-radial-menu-navigator path {
  stroke: #444;
  stroke-width: 2px;
}
</style>
