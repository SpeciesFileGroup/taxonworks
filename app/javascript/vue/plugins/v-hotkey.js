import VueHotkey from 'v-hotkey'

export default {
  beforeMount: VueHotkey.directive.bind,
  updated: VueHotkey.directive.componentUpdated,
  unmounted: VueHotkey.directive.unbind
}
