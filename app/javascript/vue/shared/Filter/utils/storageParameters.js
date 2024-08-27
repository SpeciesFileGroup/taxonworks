const FILTER_QUERY_STORAGE_KEY = 'linkerQuery'

export class LinkerStorage {
  static getParameters() {
    return JSON.parse(localStorage.getItem(FILTER_QUERY_STORAGE_KEY))
  }

  static saveParameters(parameters) {
    localStorage.setItem(FILTER_QUERY_STORAGE_KEY, JSON.stringify(parameters))
  }

  static removeParameters() {
    localStorage.removeItem(FILTER_QUERY_STORAGE_KEY)
  }
}
