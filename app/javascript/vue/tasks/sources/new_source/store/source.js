import { defineStore } from 'pinia'
import { Source, SoftValidation, Documentation } from '@/routes/endpoints'
import { useSettingStore } from './settings'
import { SOURCE_BIBTEX, SOURCE } from '@/constants'
import { smartSelectorRefresh } from '@/helpers/smartSelector'
import { removeFromArray } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import makeSource from '../const/source'
import setParam from '@/helpers/setParam'

export const useSourceStore = defineStore('source', {
  state: () => ({
    documentation: [],
    source: makeSource(),
    softValidation: undefined
  }),

  actions: {
    cloneSource() {
      Source.clone(this.source.id, { extend: ['roles'] }).then(({ body }) => {
        this.documentation = []
        this.setSource(body)
        this.loadSoftValidations(body.global_id)

        TW.workbench.alert.create('Source was successfully cloned.', 'notice')
      })
    },

    loadSoftValidations(globalId) {
      SoftValidation.find(globalId).then(({ body }) => {
        this.softValidation = {
          sources: {
            list: body.soft_validations.length ? [body] : [],
            title: 'Source'
          }
        }
      })
    },

    async convertToBibtex() {
      const settings = useSettingStore()
      const sourceId = this.source?.id
      if (!sourceId) return

      settings.isConverting = true

      try {
        const { body } = await Source.update(sourceId, {
          source: { convert_to_bibtex: true },
          extend: ['roles']
        })

        if (body.type === SOURCE_BIBTEX) {
          this.source = makeSource(body)
          this.loadSoftValidations(body.global_id)

          setParam(RouteNames.NewSource, 'source_id', body.id)

          TW.workbench.alert.create(
            'Source was successfully converted.',
            'notice'
          )
        } else {
          TW.workbench.alert.create(
            'Source needs to be converted manually',
            'error'
          )
        }
      } catch (error) {
        TW.workbench.alert.create('Conversion failed.', 'error')
      } finally {
        settings.isConverting = false
        settings.saving = false
      }
    },

    async loadSource(id) {
      try {
        const { body } = await Source.find(id, { extend: 'roles' })

        this.source = makeSource(body)
        this.loadSoftValidations(body.global_id)

        Documentation.where({
          documentation_object_id: id,
          documentation_object_type: SOURCE
        }).then(({ body }) => {
          this.documentation = body
        })

        setParam(RouteNames.NewSource, 'source_id', body.id)
      } catch {
        TW.workbench.alert.create('No source was found with that ID.', 'alert')
        history.pushState(null, null, RouteNames.NewSource)
      }
    },

    async removeDocumentation(documentation) {
      Documentation.destroy(documentation.id).then(() => {
        removeFromArray(this.documentation, documentation)
      })
    },

    setSource(source) {
      this.source = makeSource(source)
      setParam(RouteNames.NewSource, 'source_id', source.id)
    },

    async convertToBibtex() {
      try {
        const { body } = await Source.update(this.source.id, {
          source: { convert_to_bibtex: true },
          extend: ['roles']
        })

        if (body.type === SOURCE_BIBTEX) {
          this.setSource(body)
          this.loadSoftValidations(body.global_id)
          TW.workbench.alert.create(
            'Source was successfully converted.',
            'notice'
          )
        } else {
          TW.workbench.alert.create(
            'Source needs to be converted manually',
            'error'
          )
        }
      } catch {}
    },

    async save() {
      const settings = useSettingStore()

      settings.saving = true

      try {
        const payload = { source: this.source, extend: 'roles' }

        const { body } = this.source.id
          ? await Source.update(this.source.id, payload)
          : await Source.create(payload)

        this.setSource(body)
        this.loadSoftValidations(body.global_id)
        smartSelectorRefresh()
        TW.workbench.alert.create('Source was successfully saved.', 'notice')
      } catch {
      } finally {
        settings.saving = false
      }
    },

    async createBibTexSource(bibtexInput) {
      this.saving = true
      store.reset()

      try {
        const { body } = await Source.create({ bibtex_input: bibtexInput })

        store.source = makeSource(body)

        if (body.journal) {
          Serial.where({ name: body.journal }).then(({ body }) => {
            const [serial] = body

            if (serial) {
              store.source.serial_id = serial.id
            }
          })
        }

        setParam(RouteNames.NewSource, 'source_id', body.id)
        emit('close', true)
        TW.workbench.alert.create('New source from BibTeX created.', 'notice')
      } catch {
      } finally {
        this.saving = false
      }
    },

    saveDocumentation(documentation) {
      if (documentation.id) {
        const document = this.documentation.find(
          (item) => item.document_id === documentation.id
        )

        Document.update(documentation.id, { document: documentation }).then(
          ({ body }) => {
            document.document.is_public = body.is_public
          }
        )
      } else {
        Documentation.create({ documentation }).then(({ body }) => {
          this.documentation.push(body)
          TW.workbench.alert.create(
            'Documentation was successfully created.',
            'notice'
          )
        })
      }
    },

    reset(data = {}) {
      const settings = useSettingStore()
      const source = makeSource()
      const locked = Object.entries(settings.lock)

      locked.forEach(([key, value]) => {
        if (value) {
          source[key] = this.source[key]
        }
      })

      this.setSource({ ...data })
      this.documentation = []
      this.softValidation = undefined

      history.pushState(null, null, RouteNames.NewSource)
    }
  }
})
