import { defineStore } from 'pinia'
import { Composition, CompositionItem, Depiction } from '@/routes/endpoints'
import {
  compositionItemToItem,
  groupAttributes,
  groupToRegion,
  itemAttributes,
  itemKey,
  regionKey
} from '../adapters/compositionItem'
import { computeChanges, countChanges } from '../adapters/changes'
import { getImageId } from '../adapters/source'
import {
  LAYOUT_ITEM_GROUP_ITEM,
  LAYOUT_ITEM_LIGHT_TABLE_ITEM,
  LAYOUT_LIGHT_TABLE
} from '@/constants'

const MAX_PARALLEL_REQUESTS = 6
const IMAGES_PER_DEPICTION_REQUEST = 50
const MAX_DEPICTIONS_PER_REQUEST = 1000

export async function runAll(entries, request) {
  for (let i = 0; i < entries.length; i += MAX_PARALLEL_REQUESTS) {
    await Promise.allSettled(
      entries.slice(i, i + MAX_PARALLEL_REQUESTS).map(request)
    )
  }
}

export default defineStore('lightTable', {
  state: () => ({
    composition: null,
    draftName: '',
    sessionKey: 0,
    filterImages: [],
    initialItems: [],
    initialRegions: [],
    layout: null,
    baseline: { items: new Map(), groups: new Map() },
    serverIds: new Map(),
    isLoading: false,
    isSaving: false
  }),

  getters: {
    changes: (state) =>
      computeChanges({
        layout: state.layout,
        baseline: state.baseline,
        serverIds: state.serverIds
      }),

    changeCount() {
      return countChanges(this.changes)
    },

    hasChanges() {
      return this.changeCount > 0
    },

    isNew: (state) => !state.composition,

    canSave() {
      if (this.isSaving) return false

      return this.isNew ? !!this.draftName.trim() : this.hasChanges
    }
  },

  actions: {
    reset() {
      this.composition = null
      this.draftName = ''
      this.sessionKey++
      this.initialItems = []
      this.initialRegions = []
      this.layout = null
      this.baseline = { items: new Map(), groups: new Map() }
      this.serverIds = new Map()
    },

    async loadComposition(id) {
      this.isLoading = true

      try {
        const [{ body: composition }, { body: compositionItems }] =
          await Promise.all([
            Composition.find(id),
            Composition.compositionItems(id, {
              extend: ['composition_item_object']
            })
          ])

        const groups = compositionItems.filter(
          (c) => c.type === LAYOUT_ITEM_GROUP_ITEM
        )
        const items = compositionItems.filter(
          (c) =>
            c.type === LAYOUT_ITEM_LIGHT_TABLE_ITEM && c.composition_item_object
        )
        const groupsById = new Map(groups.map((g) => [g.id, g]))
        const depictionsByImage = await this.loadImageDepictions(
          items.map((c) =>
            getImageId(c.composition_item_object_type, c.composition_item_object)
          )
        )

        this.reset()
        this.composition = composition

        groups.forEach((g) => {
          this.serverIds.set(regionKey(g.id), g.id)
          this.baseline.groups.set(g.id, groupAttributes(g))
        })

        items.forEach((c) => {
          this.serverIds.set(itemKey(c.id), c.id)
          this.baseline.items.set(c.id, itemAttributes(c))
        })

        this.initialRegions = groups.map(groupToRegion)
        this.initialItems = items.map((c) =>
          compositionItemToItem(
            c,
            groupsById.get(c.parent_id),
            depictionsByImage.get(
              getImageId(
                c.composition_item_object_type,
                c.composition_item_object
              )
            ) || []
          )
        )
      } finally {
        this.isLoading = false
      }
    },

    async loadImageDepictions(imageIds) {
      const ids = [...new Set(imageIds)]
      const depictionsByImage = new Map(ids.map((id) => [id, []]))
      const chunks = []

      for (let i = 0; i < ids.length; i += IMAGES_PER_DEPICTION_REQUEST) {
        chunks.push(ids.slice(i, i + IMAGES_PER_DEPICTION_REQUEST))
      }

      await runAll(chunks, async (chunk) => {
        const { body } = await Depiction.filter({
          image_id: chunk,
          per: MAX_DEPICTIONS_PER_REQUEST,
          extend: ['depiction_object']
        })

        body.forEach((d) => depictionsByImage.get(d.image_id)?.push(d))
      })

      return depictionsByImage
    },

    setLayout(layout) {
      this.layout = layout
    },

    updateComposition(attributes) {
      return Composition.update(this.composition.id, {
        composition: attributes
      }).then(({ body }) => {
        this.composition = body
      })
    },

    async createComposition() {
      const { body } = await Composition.create({
        composition: {
          name: this.draftName.trim(),
          type: LAYOUT_LIGHT_TABLE
        }
      })

      this.composition = body
      this.draftName = ''
    },

    async save() {
      if (!this.canSave) return
      this.isSaving = true

      if (this.isNew) {
        try {
          await this.createComposition()
        } catch {
          this.isSaving = false
          return
        }
      }

      const compositionId = this.composition.id

      const createItem = async ({ key, attributes }, type) => {
        const { body } = await CompositionItem.create({
          composition_item: {
            ...attributes,
            type,
            composition_id: compositionId
          }
        })

        this.serverIds.set(key, body.id)
        this.storeBaseline(body)
      }

      const updateItem = async ({ id, attributes }) => {
        const { body } = await CompositionItem.update(id, {
          composition_item: attributes
        })

        this.storeBaseline(body)
      }

      const destroyItem = async ({ id }, collection) => {
        await CompositionItem.destroy(id)
        collection.delete(id)

        for (const [key, serverId] of this.serverIds) {
          if (serverId === id) this.serverIds.delete(key)
        }
      }

      try {
        let changes = this.changes

        await runAll(changes.groupCreates, (c) =>
          createItem(c, LAYOUT_ITEM_GROUP_ITEM)
        )
        await runAll(changes.groupUpdates, updateItem)

        changes = this.changes

        await runAll(changes.itemCreates, (c) =>
          createItem(c, LAYOUT_ITEM_LIGHT_TABLE_ITEM)
        )
        await runAll(changes.itemUpdates, updateItem)
        await runAll(changes.itemDestroys, (c) =>
          destroyItem(c, this.baseline.items)
        )
        await runAll(changes.groupDestroys, (c) =>
          destroyItem(c, this.baseline.groups)
        )

        if (this.hasChanges) {
          TW.workbench.alert.create('Some changes could not be saved.', 'error')
        } else {
          TW.workbench.alert.create(
            'Light table was successfully saved.',
            'notice'
          )
        }
      } finally {
        this.isSaving = false
      }
    },

    storeBaseline(compositionItem) {
      if (compositionItem.type === LAYOUT_ITEM_GROUP_ITEM) {
        this.baseline.groups.set(
          compositionItem.id,
          groupAttributes(compositionItem)
        )
      } else {
        this.baseline.items.set(
          compositionItem.id,
          itemAttributes(compositionItem)
        )
      }
    }
  }
})
