let configuration = {}

export function configure(incomingConfiguration) {
  configuration = {
    env: incomingConfiguration.env,
    apiVersion: "v2",
    clientName: incomingConfiguration.client_name,
    key: incomingConfiguration.key,
    product: incomingConfiguration.product,
  }
}

export function initPlaid(options = {}) {
  return Plaid.create({ ...configuration, ...options })
}
