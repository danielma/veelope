import { capitalize, camelCase } from "utils/text"
import * as components from "glob:components/*.js"

const renamed = { }

window.camelCase = camelCase

Object.keys(components).forEach((name) => {
  const desiredName = capitalize(camelCase(name))
  renamed[desiredName] = components[name]
  exports[desiredName] = components[name]
})

module.exports = renamed
