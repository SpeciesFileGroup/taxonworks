const DATABASE_NAME = 'TaxonWorks'
const SCHEMA_VERSION = 1
const SCHEMA_STORE = [
  {
    name: 'Pdf',
    options: { keyPath: 'userAndProjectId' }
  }
]

class IndexedDBStorage {
  constructor (dbName, version, schema) {
    this.db = new Promise((resolve, reject) => {
      const indexedDB = window.indexedDB
      const db = indexedDB.open(dbName, version)

      db.onupgradeneeded = () => {
        this._createStore(db.result, schema)
        resolve(db.result)
      }

      db.onsuccess = () => {
        resolve(db.result)
      }

      db.onerror = (e) => {
        reject(e)
      }
    })
  }

  _createStore (db, schema) {
    schema.forEach(store => {
      db.createObjectStore(store.name, store.options)
    })
  }

  async _makeTransaction (store, type) {
    const db = await this.db
    const transaction = db.transaction([store], type)
    const objectStore = transaction.objectStore(store)

    return objectStore
  }

  async add (store, data, key) {
    const transaction = await this._makeTransaction(store, 'readwrite')

    transaction.put(data, key)
  }

  async put (store, data, key) {
    const transaction = await this._makeTransaction(store, 'readwrite')

    transaction.put(data, key)
  }

  async removeRecord (store, index) {
    const transaction = await this._makeTransaction(store, 'readwrite')

    transaction.delete(index)
  }

  get (store, index) {
    return new Promise((resolve, reject) => {
      this._makeTransaction(store, 'readonly').then(transaction => {
        const request = transaction.get(index)

        request.onsuccess = (e) => {
          resolve(request.result)
        }
        request.onerror = e => {
          reject(e)
        }
      })
    })
  }

  async deleteObjectStore (store) {
    const db = await this.db

    db.deleteObjectStore(store)
  }

  async getDB () {
    return await this.db
  }
}

export default new IndexedDBStorage(DATABASE_NAME, SCHEMA_VERSION, SCHEMA_STORE)
