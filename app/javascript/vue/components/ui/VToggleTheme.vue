<template>
  <div
    class="toggle-theme-container"
    @click="toggleTheme"
  >
    <div
      class="toggle-theme-button"
      type="button"
      :title="
        themeMode === themeModes.light
          ? 'Change to dark mode'
          : 'Change to light mode'
      "
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-4 w-4"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        stroke-width="2"
      >
        <path
          v-if="themeMode === themeModes.dark"
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
        />

        <path
          v-else
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
        />
      </svg>
    </div>
    <span>Theme ({{ themeMode }})</span>
  </div>
</template>

<script setup>
import { watch, ref } from 'vue'

const themeModes = {
  dark: 'dark',
  light: 'light'
}
const themeMode = ref(null)

if (
  localStorage.theme === 'dark' ||
  (!('theme' in localStorage) &&
    window.matchMedia('(prefers-color-scheme: dark)').matches)
) {
  themeMode.value = 'dark'
} else {
  themeMode.value = 'light'
}

watch(
  themeMode,
  (value, oldValue) => {
    document.documentElement.classList.add(value)
    document.documentElement.classList.remove(oldValue)
    localStorage.setItem('theme', value)
  },
  { immediate: true }
)

const toggleTheme = () => {
  if (themeMode.value === themeModes.dark) {
    themeMode.value = themeModes.light
  } else {
    themeMode.value = themeModes.dark
  }
}
</script>

<style>
.toggle-theme-container {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.toggle-theme-button {
  display: flex;
  background-color: transparent;
  border: none;
  text-transform: capitalize;
  padding: 0;
  svg {
    stroke: var(--text-color);
  }
}
</style>
