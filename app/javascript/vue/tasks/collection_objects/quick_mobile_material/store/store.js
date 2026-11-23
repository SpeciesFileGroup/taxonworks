import { defineStore } from 'pinia'
import {
  Composition,
  Namespace,
  QuickMobileMaterial,
  Repository
} from '@/routes/endpoints'
import { getCurrentProjectId, getCurrentUserId } from '@/helpers'
import { LAYOUT_TASK } from '@/constants'
import { STATUS, TASK_TOKEN_STATE } from '../constants'

// Settings persist client-side per User + Project until the User changes them
function settingsKey() {
  return `quickMobileMaterial-u${getCurrentUserId()}-p${getCurrentProjectId()}`
}

function readSettings() {
  try {
    return JSON.parse(localStorage.getItem(settingsKey())) || {}
  } catch {
    return {}
  }
}

export default defineStore('quickMobileMaterial', {
  state: () => ({
    composition: null,
    repository: null,
    namespace: null,
    qrCode: null, // { svg, expiresAt }
    taskToken: null, // { state, expires_at }, the cache entry
    wasInvalidated: false,
    items: [],
    isLoading: false,
    now: Date.now()
  }),

  getters: {
    isQrCodeLive(state) {
      return (
        !!state.qrCode &&
        state.taskToken?.state === TASK_TOKEN_STATE.Pending &&
        new Date(state.qrCode.expiresAt).getTime() > state.now
      )
    },

    // Seconds until the live token (QR or active session) expires
    secondsLeft(state) {
      const expiresAt =
        state.taskToken?.state === TASK_TOKEN_STATE.Active
          ? state.taskToken.expires_at
          : state.qrCode?.expiresAt

      if (!expiresAt) return 0

      return Math.max(
        0,
        Math.round((new Date(expiresAt).getTime() - state.now) / 1000)
      )
    },

    status(state) {
      const live = this.secondsLeft > 0

      if (state.taskToken?.state === TASK_TOKEN_STATE.Active && live) {
        return STATUS.Connected
      }

      if (state.taskToken?.state === TASK_TOKEN_STATE.Pending && live) {
        return STATUS.Waiting
      }

      if (state.wasInvalidated) return STATUS.Invalidated
      if (state.qrCode || state.taskToken) return STATUS.Expired

      return STATUS.NotStarted
    }
  },

  actions: {
    tick() {
      this.now = Date.now()
    },

    async loadSettings() {
      const { repository_id, namespace_id } = readSettings()

      const [repository, namespace] = await Promise.all([
        repository_id
          ? Repository.find(repository_id).then(({ body }) => body).catch(() => null)
          : null,
        namespace_id
          ? Namespace.find(namespace_id).then(({ body }) => body).catch(() => null)
          : null
      ])

      this.repository = repository
      this.namespace = namespace
    },

    saveSettings() {
      localStorage.setItem(
        settingsKey(),
        JSON.stringify({
          repository_id: this.repository?.id || null,
          namespace_id: this.namespace?.id || null
        })
      )
    },

    // Changing a setting ends the live token and renders a new QR code
    async setSetting(name, value) {
      this[name] = value
      this.saveSettings()

      if (this.composition) await this.issueTaskToken()
    },

    async loadComposition(id) {
      this.isLoading = true

      try {
        const { body } = await Composition.find(id)

        this.composition = body
        this.qrCode = null
        await Promise.all([this.loadItems(), this.loadTaskTokenStatus()])
      } finally {
        this.isLoading = false
      }
    },

    async createComposition(name) {
      const { body } = await Composition.create({
        composition: { name, type: LAYOUT_TASK }
      })

      this.composition = body
      this.items = []
      await this.issueTaskToken()
    },

    // Never called automatically, it would end an active Mobile session
    async issueTaskToken() {
      const { body } = await QuickMobileMaterial.issueTaskToken({
        composition_id: this.composition.id,
        repository_id: this.repository?.id,
        namespace_id: this.namespace?.id
      })

      this.qrCode = { svg: body.svg, expiresAt: body.expires_at }
      this.taskToken = body.task_token_status
      this.wasInvalidated = false
      this.tick()
    },

    async invalidateTaskToken() {
      await QuickMobileMaterial.invalidateTaskToken()

      this.qrCode = null
      this.taskToken = null
      this.wasInvalidated = true
    },

    async loadTaskTokenStatus() {
      const { body } = await QuickMobileMaterial.taskTokenStatus()

      this.taskToken = body.task_token_status
      this.tick()
    },

    async loadItems() {
      if (!this.composition) return

      const { body } = await QuickMobileMaterial.items({
        composition_id: this.composition.id
      })

      this.items = body
    },

    // Manual refresh, there is no polling
    async refresh() {
      this.isLoading = true

      try {
        await Promise.all([this.loadItems(), this.loadTaskTokenStatus()])
      } finally {
        this.isLoading = false
      }
    }
  }
})
