# Project Architecture Overview

This document describes the JavaScript project architecture to help AI tools (such as Claude) and human developers quickly understand the environment, conventions, and extension points of the system.

---

## 1. Technology Stack

- **Language:** JavaScript
- **Main framework**: Vue.js v3
- **Package manager**: npm
- **Styling:** Vanilla CSS, SCSS

---

## 2. General Project Structure

```txt
root/
|  app/
|  └─ javascript/
|     ├─ packs
|     ├─ vanilla/
|     |  ├─ initializers/
|     |  ├─ utils/
|     |  ├─ views/
|     └─ vue/
|        ├─ assets/
|        ├─ components/
|        ├─ composables/
|        ├─ constants/
|        ├─ directives/
|        ├─ helpers/
|        ├─ initializers/
|        ├─ plugins/
|        ├─ shared/
|        ├─ utils/
|        ├─ services/
|        └─ utils/
└─ package.json

```

> **Note:** The structure may vary slightly depending on the application or task type.

---

## 3. Global Components

**Global components** are reusable across multiple applications or tasks and **must not depend on domain-specific business logic**.

**Location:**

```txt
app/javascript/vue/components/
```

**Conventions:**

- Must not assume task-specific global state
- Must receive data exclusively via `props`, except for complex forms, in that case use Pinia as state management

Examples:

- Autocomplete
- Buttons
- Modal
- Icons
- Generic layout components

---

## 4. Task-based Applications

The project is organized into **independent applications**, each focused on a single task or feature.

**Location:**

```txt
app/javascript/vue/tasks
```

Each app lives in its own directory:

```txt
app/javascript/vue/tasks/<model-name>/<task-name>
├─ components/
├─ adapters/
├─ utils/
├─ store
|  └─ store.js
├─ app.js
└─ main.js
```

**Principles:**

- Each app is self-contained
- Apps may use global components
- Apps must not directly depend on other apps
- Use Pinia when you need a centralized, global, and reactive state shared across multiple components in the application

---

## 5. Creating a New App

To create a new task-based application:

1. Create a directory under `app/javascript/vue/tasks/<model>/<new-task>`
2. Define an `main.js` as the entry point
3. Register the entry point in `app/javascript/packs/application.js`
4. Reuse global components whenever possible

---

## 6. Composables / Hooks

Reusable Vue.js logic that is independent from UI concerns.

**Location:**

```txt
app/javascript/vue/composables/
```

Examples:

- Resize / observer logic
- Reactive helpers
- Handle events

---

## 7. Helpers / Utils

Reusable javascript logic.

**Location:**

```txt
app/javascript/vue/helpers/
app/javascript/vue/utils/
```

Examples:

- Sort arrays
- Transform strings
- Date formats

---

---

## 8. Initializers

JavaScript files that listen for page load events and mount Vue.js applications by scanning the DOM for specific data attributes.

**Location:**

```txt
app/javascript/vue/initializers/
```

---

## 9. Services and Data Access

Encapsulate API calls.

**Location:**

```txt
app/javascript/vue/routes/endpoints/
```

Rules:

- Use ajaxCall to add new calls when baseCRUD does not provide the necessary endpoints
- Must not import components
- Should be framework-agnostic

---

## 10. Import Conventions

- Prefer absolute imports from `vue/`
- Use `@` as alias of `vue/`
- Global components may be imported from any app
- Apps must not import each other

Example:

```js
import BaseButton from '@/components/ui/Modal.vue'
```

---

## 11. AI Usage Guidelines

### Allowed

- Create new task-based apps following the defined structure
- Add global components when reuse is appropriate
- Add composables or services respecting separation of concerns

### Not Allowed

- Introduce cross-app dependencies
- Add business logic to global components
- Bypass established directory conventions

---

## 12. Architectural Principles

- **Separation of concerns**
- **Low coupling between apps**
- **High reuse via global components and composables**
- **Explicit boundaries between UI, logic, and data access**
