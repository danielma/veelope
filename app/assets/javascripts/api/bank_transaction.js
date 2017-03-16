import { ajax } from "./base"

export function update(id, params) {
  return ajax.put(
    `/transactions/${id}`,
    { bank_transaction: params },
  )
}

export default exports
