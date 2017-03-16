let globalUniqueIndex = 0

export function uniqueId(prefix = "") {
  return `${prefix}${globalUniqueIndex += 1}`
}
